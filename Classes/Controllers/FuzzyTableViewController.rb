# FuzzyTableViewController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.


class FuzzyTableViewController
  
  include Constants

  attr_accessor :tableView, :allRecords, :records, :queue, :fuzzyWindowController

  def initialize
    @records = []
    @queue = NSOperationQueue.alloc.init
    @nc = NSNotificationCenter.defaultCenter
    @fuzzyWindowController = fuzzyWindowController
  end
  
  def awakeFromNib
    @nc.addObserver(self,
        selector:"anyThread_HandleRecordCreated:" ,
            name:TFRecordCreatedNotification,
          object:nil)
    @nc.addObserver(self,
        selector:"handleAllRecordsCreated:" ,
            name:TFAllRecordsCreatedNotification,
          object:nil)
    
  end

  def loadFilesFromProjectRoot(theProjectRoot)
    FuzzyRecord.recordsForProjectRoot(theProjectRoot, withFuzzyTableViewController:self)
  end

  def reset
    @allRecords = []
    @records = []
    tableView.reloadData
  end

  ##
  # Text entered into the search field calls this method.

  def searchForString(searchString)
    if searchString.strip.length == 0
      FuzzyRecord.resetMatchesForRecords!(@allRecords)
    end
    filterRecordsForString(searchString)
  end

  def filterRecordsForString(searchString)
    # BUG: If called async, needs to lock around table redrawing or
    # setting records.

    # TODO: For efficiency, examine previous search string and search
    # filtered records if new search is a continuation of a previous
    # search.
    filteredRecords = FuzzyRecord.filterRecords(@allRecords,
                                                forString:searchString)

    performSelectorOnMainThread("didSearchForString:",
                                withObject:filteredRecords,
                                waitUntilDone:true)
    @fuzzyWindowController.updateStatusLabel
  end

  def didSearchForString(filteredRecords)
    @records = filteredRecords
    tableView.reloadData
    selectFirstRow
  end

  def selectFirstRow
    if @records.size > 0
      tableView.selectRowIndexes(NSIndexSet.indexSetWithIndex(0),
                                 byExtendingSelection:false)
      tableView.scrollRowToVisible(0)
    end
  end

  def selectPreviousRow
    # Select next row up, or last row if none are selected.
    selectedRowIndex = tableView.selectedRow
    if (1..@records.size).include?(selectedRowIndex)
      selectedRowIndex -= 1
    else
      selectedRowIndex = @records.size - 1
    end
    tableView.selectRowIndexes(NSIndexSet.indexSetWithIndex(selectedRowIndex),
                               byExtendingSelection:false)
    tableView.scrollRowToVisible(selectedRowIndex)
  end

  def selectNextRow
    # Select next row down, or first row if none are selected.
    selectedRowIndex = tableView.selectedRow
    if (0..(@records.size-2)).include?(selectedRowIndex)
      selectedRowIndex += 1
    else
      selectedRowIndex = 0
    end
    tableView.selectRowIndexes(NSIndexSet.indexSetWithIndex(selectedRowIndex),
                               byExtendingSelection:false)
    tableView.scrollRowToVisible(selectedRowIndex)
  end

  ## NSTableDataSource methods

  def numberOfRowsInTableView(tableView)
    @records.length
  end

  def tableView(tableView, objectValueForTableColumn:column, row:row)
    if row < @records.size
      # There is only one column
      return @records[row].filePath
    end
    # Should be an error if execution reaches here
    nil
  end

  def tableView(tableView, willDisplayCell:cell, forTableColumn:column, row:row)
    cell.setRepresentedObject(@records[row])
  end

  def didClickRow(sender)
    handleRowClick(tableView.clickedRow)
  end

  def handleRowClick(rowId)
    rowId = 0 if rowId == -1
    if record = @records[rowId]
      FuzzyRecord.storeRecentlyOpenedRecord(record)
      # TODO: Close window when clicked with the mouse
      
      editorApplicationName = NSApp.delegate.sessionConfig.editorName
      editorApplicationName =
        NSUserDefaults.standardUserDefaults.stringForKey('editorApplicationName') if editorApplicationName.empty?

      if (editorApplicationName.strip == "")
        # Haven't a clue where to open the file
        return false
      end

      NSWorkspace.sharedWorkspace.openFile(record.absFilePath,
                                           withApplication:editorApplicationName)

      # Reset for next search
      searchForString("")
      return true
    end
  end
  

  # Notifications will be sent from many threads but GUI activity needs to take place
  # on the main thread, hence this collect and forward pair
  # i.e.
  #   anyThread_HandleRecordCreated and 
  #   mainThread_handleRecordCreated
  def anyThread_HandleRecordCreated(notification)
    performSelectorOnMainThread(:"mainThread_handleRecordCreated:", withObject:notification, waitUntilDone:false)
  end
  
  def mainThread_handleRecordCreated(notification)
    @records << notification.object
    tableView.reloadData
    @fuzzyWindowController.updateProgressBarWithDoubleValue(@records.size)
  end
  
  def createAllRecords
    @allRecords = @records
  end
  
  def handleAllRecordsCreated(notification)
    @records = notification.object
    createAllRecords
    @fuzzyWindowController.didFinishLoadingFilesFromProjectRoot
  end

end

