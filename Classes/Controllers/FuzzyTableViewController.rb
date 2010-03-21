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
    #     loadFilesFromProjectRoot(File.expand_path("~/repos-private/blog-nesta"))
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
    if searchString.length
      @records = @allRecords.select {|r| r.fuzzyInclude?(searchString) }
    else
      @records = @allRecords
    end
    tableView.reloadData
  end

  # NSTableDataSource methods
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

end

