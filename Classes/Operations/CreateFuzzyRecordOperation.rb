# CreateFuzzyRecordOperation.rb
# PeepOpen
#
# Created by Martin Hawkins on 26/01/2011.
# Copyright 2011 Topfunky Corporation. All rights reserved.


class CreateFuzzyRecordOperation < NSOperation
  def initWithProjectRoot(theProjectRoot, andFilePath:relativeFilename)
    init
    @projectRoot = theProjectRoot
    @relativeFilename = relativeFilename
    self
  end
  
  def main
    unless isCancelled
      fuzzyRecord = FuzzyRecord.alloc.initWithProjectRoot(@projectRoot, filePath:@relativeFilename)
      NSNotificationCenter.defaultCenter.postNotificationName(TFRecordCreatedNotification, object:fuzzyRecord)
    end
  end
  
  def isConcurrent
    true
  end
  
end