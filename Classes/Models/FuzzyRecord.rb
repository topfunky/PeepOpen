# FuzzyRecord.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

require 'Constants'
include Constants

class FuzzyRecord

  attr_accessor *[:projectRoot, :filePath,
                  :scmStatus, :scmName,
                  :codeObjectName, :codeObjectNames,
                  :matchedRanges, :matchesOnFilenameScore, :longestMatch]

  MAX_SCORE = 10_000

  def self.discoverProjectRootForDirectoryOrFile(directoryOrFile)
    normalizedPath = directoryOrFile.gsub(/[\/']$/, '') # Normalize: remove trailing slash

    # If a directory was passed, assume it's the project root 
    # and don't do further searching.
    if File.directory?(normalizedPath)
      NSLog("Using Directory as Project Root: #{normalizedPath}") # DEBUG
      return normalizedPath, true
    end

    projectRoot = ''
    projectRootFoundFlag = false

    projectRootRegex = Regexp.new(NSUserDefaults.standardUserDefaults.stringForKey("projectRootRegex"))

    fileManager = NSFileManager.defaultManager
    pathComponents = normalizedPath.pathComponents
    NSLog("Finding Project Root with Path Components: #{pathComponents.inspect}") # DEBUG
    (pathComponents.length - 1).downto(0) do |index|
      path = NSString.pathWithComponents(pathComponents[0..index])
      next if File.file?(path)
      directoryContents = fileManager.contentsOfDirectoryAtPath(path, error:nil)
      if directoryContents
        directoryContents.map {|f|
          if f.match(projectRootRegex)
            projectRoot, projectRootFoundFlag = path.to_s, true
            break
          end
        }
      end
    end

    if projectRoot.empty?
      projectRoot = File.directory?(normalizedPath) ? normalizedPath : File.dirname(normalizedPath)
    end

    NSLog("Using Project Root: #{projectRoot}") if projectRootFoundFlag # DEBUG
    return projectRoot, projectRootFoundFlag
  end

  # Cache is a dictionary of project roots with arrays of recent files
  # and records.
  #
  #   {
  #     "/var/www/project" => {
  #       :recentlyOpenedRecords => [],
  #       :records => []
  #     }
  #   }
  @@cache = {}

  def self.recordsForProjectRoot(theProjectRoot, withFuzzyTableViewController:fuzzyTableViewController)
    cacheScmStatus(theProjectRoot)

    if records = cachedRecordsForProjectRoot(theProjectRoot)
      # Get fresh scmStatus every time
      records.each { |r| r.scmStatus = nil }
      NSNotificationCenter.defaultCenter.postNotificationName(TFAllRecordsCreatedNotification, object:records)
      return
    end

    loadRecordsWithProjectRoot(theProjectRoot, withFuzzyTableViewController:fuzzyTableViewController)
  end

  def self.cacheForProjectRoot(theProjectRoot)
    return nil if @@cache.nil?
    @@cache[theProjectRoot]
  end

  ##
  # Returns only the cached records for a project, or nil.

  def self.cachedRecordsForProjectRoot(theProjectRoot)
    if cacheHash = cacheForProjectRoot(theProjectRoot)
      if records = cacheHash[:records]
        return records
      end
    end
    return nil
  end

  ##
  # Store records for faster launch.

  def self.setCacheRecords(theRecords, forProjectRoot:theProjectRoot)
    @@cache ||= {}
    if @@cache[theProjectRoot].nil?
      @@cache[theProjectRoot] = {}
    end
    @@cache[theProjectRoot][:records] = theRecords
  end

  ##
  # Add a single record to the existing cache for a project.

  def self.addRecord(theRecord, toCacheForProjectRoot:theProjectRoot)
    @@cache ||= {}
    if @@cache[theProjectRoot].nil?
      @@cache[theProjectRoot] = {
        :records => []
      }
    end
    @@cache[theProjectRoot][:records] << theRecord
  end

  def self.flushCache(theProjectRoot)
    return if @@cache.nil?
    if @@cache[theProjectRoot]
      if @@cache[theProjectRoot][:records]
        @@cache[theProjectRoot][:records] = nil
        @@cache[theProjectRoot][:recentlyOpenedRecords] = nil
        # TODO: Remove entries in :recentlyOpenedRecords if missing
      end
    end
  end

  ##
  # Keep last few opened records so the user can toggle between
  # recent files.

  def self.storeRecentlyOpenedRecord(theRecord)
    cacheHash = cacheForProjectRoot(theRecord.projectRoot) || {}
    if recentArray = cacheHash[:recentlyOpenedRecords]
      if recentArray.include?(theRecord)
        # Avoid a situation where one file occupies both slots in the
        # recent files list.
        if recentArray.first == theRecord
          recentArray.reverse!
        end
      else
        recentArray << theRecord
        # Keep only two
        while recentArray.length > 2
          recentArray.shift
        end
      end
    else
      cacheHash[:recentlyOpenedRecords] = [theRecord]
    end
    @@cache[theRecord.projectRoot] = cacheHash
  end

  def self.cacheScmStatus(theProjectRoot)
    @@scmStatusDictionary = {}

    return unless NSUserDefaults.standardUserDefaults.boolForKey("scmShowMetadata")
    gitDiffAgainst = NSUserDefaults.standardUserDefaults.stringForKey("scmGitDiffAgainst")
    gitDiffAgainst = "" if (gitDiffAgainst == "Current")

    # TODO: Run async
    #
    # Run "git diff --numstat" on projectRoot and save for all
    # in an NSDictionary
    #
    # 3       1       Tests/run_suite.rb
    # -       -       Foo/Bar.rb
    projectDotGitPath =
      NSString.pathWithComponents([theProjectRoot, ".git"])
    unless NSFileManager.defaultManager.fileExistsAtPath(projectDotGitPath)
      return
    end

    shellString = NSProcessInfo.processInfo.environment.objectForKey("SHELL") || "/bin/bash"
    loginFlag = '-l'
    if shellString.match(/tcsh/)
      # NOTE: tcsh doesn't support -l unless it's the only option.
      loginFlag = ''
    end

    # TODO: Read Git info asynchronously so it doesn't block the rest of the app.
    if output = `#{shellString} #{loginFlag} -c "cd #{theProjectRoot} && git diff --numstat #{gitDiffAgainst}"`
      output.split(/\n/).each do |outputLine|
        added, deleted, filePath = outputLine.split
        added   = 30 if added.to_i   > 30
        deleted = 30 if deleted.to_i > 30
        @@scmStatusDictionary[filePath] = [added.to_i, deleted.to_i]
      end
    end
  end

  ##
  # NOTE: NSPredicate
  #     p = NSPredicate.predicateWithFormat("name = 'john'")
  #     p.evaluateWithObject({"name" => "bert"}) # => false

  def self.loadRecordsWithProjectRoot(theProjectRoot, withFuzzyTableViewController:fuzzyTableViewController)
    fuzzyTableViewController.queue.cancelAllOperations
    self.setCacheRecords([], forProjectRoot:theProjectRoot)

    maximumDocumentCount = NSUserDefaults.standardUserDefaults.integerForKey("maximumDocumentCount")

    pathOp = PathOperation.alloc.initWithProjectRoot(theProjectRoot,
                                                     maximumDocumentCount:maximumDocumentCount,
                                                     andFuzzyTableViewController:fuzzyTableViewController)
    pathOp.setQueuePriority(2.0)
    fuzzyTableViewController.queue.addOperation(pathOp)
  end

  def self.filterRecords(records, forString:searchString, whitespaceSearchCharacter:wildcardCharacter)
    correctedSearchString = searchString.gsub(" ", wildcardCharacter).strip # Treat spaces as special
    if correctedSearchString.length == 0
      filteredRecords = records
    else
      filteredRecords = records.select { |r|
        r.fuzzyInclude?(correctedSearchString)
      }
    end
    sortedRecords =
      filteredRecords.sort_by { |record| [ -record.matchesOnFilenameScore,
                                           record.matchScore,
                                           -record.longestMatch,
                                           -record.modifiedAt.timeIntervalSince1970,
                                           record.filePath.length ] }
    if (correctedSearchString.length == 0) && (records.first != nil)
      if cacheHash = self.cacheForProjectRoot(records.first.projectRoot)
        if recentlyOpenedRecords = cacheHash[:recentlyOpenedRecords]
          if recentlyOpenedRecords.length >= 2
            recentRecord = recentlyOpenedRecords.first

            sortedRecords.delete(recentRecord)
            sortedRecords.unshift(recentlyOpenedRecords.first)
          end
        end
      end
    end
    return sortedRecords
  end

  def self.resetMatchesForRecords!(records)
    if records
      records.map {|r| r.resetMatches! }
    end
  end

  def initWithProjectRoot(theProjectRoot, filePath:theFilePath)
    @projectRoot = theProjectRoot
    @filePath = theFilePath
    @matchedRanges = []
    self
  end

  ##
  # Finds "a/b/c" in "armadillo/bacon/cheshire"
  #
  # Returns true if the string matches this record.
  #
  # Populates @matchedRanges with an Array of NSRange objects
  # identifying the matches.

  def fuzzyInclude?(searchString)
    resetMatches!
    # TODO: Search other things like date, classes, or SCM status
    # Multiple strategies: filename, first occurrence, most
    # contiguous.
    filename = File.basename(filePath)
    if filenameMatchRanges = searchText(filename,
                                        forFirstOccurrenceOfString:searchString)
      @matchesOnFilenameScore = 1
      @matchScore = calculateMatchScoreForRanges(filenameMatchRanges)
      dirname = File.dirname(filePath)
      if dirname == "."
        @matchedRanges = filenameMatchRanges
      else
        @matchedRanges = offsetRanges(filenameMatchRanges, by:dirname.length)
      end
      return true

    elsif firstOccurrenceMatches = searchText(filePath,
                                              forFirstOccurrenceOfString:searchString)
      if reverseSearchMatches = searchInReverseForString(searchString)
        if calculateMatchScoreForRanges(reverseSearchMatches) <
            calculateMatchScoreForRanges(firstOccurrenceMatches)
          @matchedRanges = reverseSearchMatches
        else
          @matchedRanges = firstOccurrenceMatches
        end
        return true
      end
      @matchedRanges = firstOccurrenceMatches
      return true
    end
    return nil
  end

  def searchText(theText, forFirstOccurrenceOfString:searchString)
    matchingRanges = []

    upcaseText = theText.upcase
    upcaseSearchString = searchString.upcase

    upcaseSearchString.each_char do |c|
      offset = 0
      if matchingRanges.length > 0
        offset =
          matchingRanges.lastObject.location + matchingRanges.lastObject.length
      end
      if (foundIndex = upcaseText.index(c, offset))
        if contiguousMatch?(foundIndex, matchingRanges)
          lastRange       = matchingRanges.lastObject
          lastObjectIndex = matchingRanges.length - 1
          matchingRanges[lastObjectIndex] = NSMakeRange(lastRange.location,
                                                        lastRange.length + 1)
        else
          matchingRanges << NSMakeRange(foundIndex, 1)
        end
      else
        # No match or partial match
        return nil
      end
    end

    if matchingRanges.length > 0
      return matchingRanges
    end
    nil
  end

  def searchInReverseForString(searchString)
    reverseMatches = searchText(filePath.reverse,
                                forFirstOccurrenceOfString:searchString.reverse)
    if reverseMatches.length > 0
      forwardMatches = reverseMatches.reverse.map { |range|
        location = filePath.length - range.location - range.length
        NSMakeRange(location, range.length)
      }
      return forwardMatches
    end
    nil
  end

  def resetMatches!
    @matchesOnFilenameScore = 0
    @matchedRanges = nil
    @matchScore    = nil
    @longestMatch  = nil
  end

  def matchScore
    return MAX_SCORE if @matchedRanges.nil? || @matchedRanges.length == 0
    # TODO: Files with locations close together should rank higher
    #       than ones with locations farther apart.
    #       FuzzyRecord_test.rb
    #       FuzzyRecord.rb
    #       Search => fuzr.rb
    @matchScore ||= calculateMatchScoreForRanges(@matchedRanges)
  end

  def calculateMatchScoreForRanges(ranges)
    ranges.inject(0) {|memo, element|
      memo + element.location }
  end

  def longestMatch
    return 0 if @matchedRanges.nil? || @matchedRanges.length == 0
    @longestMatch ||= calculateLongestMatch(@matchedRanges)
  end

  def calculateLongestMatch(ranges)
    longest = 0
    ranges.each do |range|
      if range.length > longest
        longest = range.length
      end
    end
    return longest
  end

  def modifiedAt
    @modifiedAt ||= begin
                      NSFileManager.defaultManager.
                        attributesOfItemAtPath(absFilePath,
                                               error:nil)[NSFileModificationDate]
                    end
  end

  def scmStatus
    return @scmStatus if @scmStatus

    if statusCounts = @@scmStatusDictionary.objectForKey(filePath)
      linesAdded, linesDeleted = statusCounts
      @scmStatus = ("+" * linesAdded) + ("-" * linesDeleted)
    end
    return @scmStatus
  end

  def absFilePath
    File.join(projectRoot, filePath)
  end

  def contiguousMatch?(foundIndex, matchingRanges)
    return false if (matchingRanges.length == 0)
    lastObject = matchingRanges.lastObject
    return (lastObject.location + lastObject.length == foundIndex)
  end

  ##
  # Make a new array of ranges, moved forward by a number of
  # characters.
  #
  # Used for switching filename-only match to a full path match.

  def offsetRanges(theRanges, by:theOffset)
    theRanges.map do |range|
      NSMakeRange(range.location + theOffset + 1, range.length)
    end
  end

end

