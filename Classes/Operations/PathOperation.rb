# PathOperation.rb
# PeepOpen
#
# Created by Martin Hawkins on 23/01/2011.
# Copyright 2011 Topfunky Corporation. All rights reserved.

framework 'Foundation'

class PathOperation < NSOperation
  def initWithProjectRoot( theProjectRoot, maximumDocumentCount:maximumDocumentCount, andFuzzyTableViewController:fuzzyTableViewController)
    init
    @projectRoot = theProjectRoot
    @queue = fuzzyTableViewController.queue
    @maximumDocumentCount = maximumDocumentCount
    @fuzzyTableViewController = fuzzyTableViewController
    self
  end
  
  def strip_path(filename, root)
    if filename.start_with?(root)
      return filename[root.length..-1]
    end
    filename
  end

  def main
    fileManager = NSFileManager.defaultManager
    filenames = fileManager.contentsOfDirectoryAtPath(@projectRoot, error:nil).map {|f| @projectRoot.stringByAppendingPathComponent(f) }
      
    index = 0
    recordsSize = @fuzzyTableViewController.records.size
    
    directoryIgnoreRegex = Regexp.new(NSUserDefaults.standardUserDefaults.stringForKey("directoryIgnoreRegex"))
    fileIgnoreRegex = Regexp.new(NSUserDefaults.standardUserDefaults.stringForKey("fileIgnoreRegex"))
      
    while ( (index < filenames.length) && ((@maximumDocumentCount >= 4000) || (recordsSize < @maximumDocumentCount)) ) do
      break if isCancelled
      filename = filenames[index]
      index += 1
      next if NSWorkspace.sharedWorkspace.isFilePackageAtPath(filename)
      relativeFilename = strip_path(filename.to_s,@projectRoot + "/")
      next if relativeFilename.match(directoryIgnoreRegex)
      next if relativeFilename.match(fileIgnoreRegex)

      if File.directory?(filename)
        # TODO: Should probably ignore all dot directories
        fileManager.contentsOfDirectoryAtPath(filename, error:nil).map {|f|
          filenames.insert(index, filename.stringByAppendingPathComponent(f))
        }
        break if isCancelled
        next
      end

      createFuzzyRecordOp = CreateFuzzyRecordOperation.alloc.initWithProjectRoot(@projectRoot, andFilePath:relativeFilename)
      @queue.addOperation(createFuzzyRecordOp)
      
      recordsSize = @fuzzyTableViewController.records.size
    end # while
  end
end
