# FuzzyTableViewController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyTableViewController

  attr_accessor :tableView, :allRecords, :records

  def initialize
    @allRecords = []
    @records = []
  end

  def loadFilesFromProjectRoot(theProjectRoot)
    @allRecords = []
    @allRecords = FuzzyRecord.recordsWithProjectRoot(theProjectRoot)
    searchForString("")
  end

  ##
  # Text entered into the search field calls this method.

  def searchForString(searchString)
    if searchString.strip.length > 0
      filterRecordsForString(searchString)
    else
      FuzzyRecord.resetMatchesForRecords!(@allRecords)
      didSearchForString(@allRecords.sort_by {|record|
                           [-record.modifiedAt.timeIntervalSince1970] })
    end
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
    if row < @records.length
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
      # TODO: Close window
      editorApplicationName =
        NSUserDefaults.standardUserDefaults.stringForKey('editorApplicationName')

      case editorApplicationName
      when "MacVim"
        openFileWithMacVim(record.absFilePath)
      else
        NSWorkspace.sharedWorkspace.openFile(record.absFilePath,
                                             withApplication:editorApplicationName)
      end
    end
  end

  def openFileWithMacVim(theFilePath)
    macVimApplicationPath =
      NSWorkspace.sharedWorkspace.fullPathForApplication("MacVim")
    macVimCommandPath = NSString.pathWithComponents([macVimApplicationPath,
                                                     "Contents",
                                                     "MacOS",
                                                     "Vim"
                                                    ])
    theProcess = NSTask.alloc.init
    theProcess.setLaunchPath(macVimCommandPath)
    theProcess.setArguments(["--remote",
                             theFilePath])
    retval = theProcess.launch
  end

end

