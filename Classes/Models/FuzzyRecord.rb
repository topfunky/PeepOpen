# FuzzyRecord.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyRecord

  attr_accessor *[:projectRoot,
                  :filePath, :filePaths,
                  :modifiedAt,
                  :scmStatus, :scmName,
                  :codeObjectName, :codeObjectNames]

  def initWithProjectRoot(theProjectRoot, filePath:theFilePath)
    @projectRoot = theProjectRoot
    @filePath = theFilePath
    self
  end

  ##
  # Finds "a/b/c" in "armadillo/bacon/cheshire"
  # Returns an Array of NSRange objects identifying the matches.

  def fuzzyInclude?(searchString)
    # TODO: Search other things like date, classes, or SCM status
    filePathCharIndex = 0
    searchStringCharIndex = 0
    matchIsInProcess = false
    matchingRanges = []

    filePath.each_char do |c|
      if c == searchString[searchStringCharIndex]
        if matchIsInProcess
          lastRange       = matchingRanges.lastObject
          lastObjectIndex = matchingRanges.indexOfObjectIdenticalTo(lastRange)
          matchingRanges[lastObjectIndex] = NSMakeRange(lastRange.location,
                                                        lastRange.length + 1)
        else
          matchingRanges << NSMakeRange(filePathCharIndex, 1)
        end
        matchIsInProcess = true
        searchStringCharIndex += 1
      else
        matchIsInProcess = false
      end
      filePathCharIndex += 1
    end
    # Reject partial matches
    return nil if searchStringCharIndex < searchString.length
    
    matchingRanges.length > 0 ? matchingRanges : nil
  end

end

