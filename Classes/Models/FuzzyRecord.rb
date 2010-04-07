# FuzzyRecord.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyRecord

  attr_accessor *[:projectRoot,
                  :filePath, :filePaths,
                  :scmStatus, :scmName,
                  :codeObjectName, :codeObjectNames,
                  :matchedRanges]

  MAX_SCORE = 10_000

  def self.recordsWithProjectRoot(theProjectRoot)
    cacheScmStatus(theProjectRoot)

    records = []
    Dir[theProjectRoot + "/**/*"].each do |filename|
      next unless File.file?(filename)
      maximumDocumentCount =
        NSUserDefaults.standardUserDefaults.integerForKey("maximumDocumentCount")
      next if records.length >= maximumDocumentCount
      filename.gsub!(/^#{theProjectRoot}\//, '')
      # TODO: Store ignorable directories, files in preferences
      next if filename.match(/^(build|tmp|log|vendor\/rails)\//i)
      next if filename.match(/(\.png|\.elc|~)$/)
      records << FuzzyRecord.alloc.initWithProjectRoot(theProjectRoot,
                                                       filePath:filename)
    end

    records
  end

  def self.cacheScmStatus(theProjectRoot)
    # TODO: Run async
    #
    # Run "git diff --numstat" on projectRoot and save for all
    # in an NSDictionary
    #
    # 3       1       Tests/run_suite.rb
    # -       -       Foo/Bar.rb
    @@scmStatusDictionary = {}
    if output = `cd #{theProjectRoot} && git diff --numstat`
      output.split(/\n/).each do |outputLine|
        added, deleted, filePath = outputLine.split
        @@scmStatusDictionary[filePath] = [added.to_i, deleted.to_i]
      end
    end
  end

  def self.filterRecords(records, forString:searchString)
    records.select { |r|
      r.fuzzyInclude?(searchString)
    }.sort_by { |record| [ -record.longestMatch,
                           record.matchScore,
                           -record.modifiedAt.timeIntervalSince1970 ] }
  end

  def self.resetMatchesForRecords!(records)
    # NOTE: parallel_map is possible, but may not be any faster
    #       unless records array is large. And it causes SIGSEGV.
    records.map {|r| r.resetMatches! }
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
    # Attempts two strategies: first occurrence vs. most contiguous.
    if firstOccurrenceMatches = searchText(filePath,
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

end

