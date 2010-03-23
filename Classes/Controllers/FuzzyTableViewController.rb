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
    @records = @allRecords
    if tableView.respondsToSelector(:reloadData)
      tableView.reloadData
    end
  end

  ##
  # Text entered into the search field calls this method.

  def searchForString(searchString)
    if searchString.strip.length > 0
      filterRecordsForString(searchString)
    else
      # TODO: Reset matchedRanges and score for all records
      didSearchForString(@allRecords)
    end
  end

  # BUG: Async needs to lock around table redrawing or setting records
  def filterRecordsForString(searchString)
    filteredRecords = @allRecords.select { |r|
      r.fuzzyInclude?(searchString)
    }.sort { |a,b| a.filePath.length <=> b.filePath.length
    }.sort { |a,b| a.matchScore <=> b.matchScore }

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
      # TODO: Hide window
      system "open -a Emacs #{record.absFilePath}"
    end
  end

end

