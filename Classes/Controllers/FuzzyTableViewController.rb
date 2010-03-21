# FuzzyTableViewController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyTableViewController

  attr_accessor :tableView, :allRecords, :records

  def searchForString(searchString)
    if searchString.length
      @records = @allRecords.select {|r| r.fuzzyInclude?(searchString) }
    else
      @records = []
    end
    tableView.reloadData
  end

  def initialize
    # Dummy
    projectRoot = "~/tmp/bjeanes-dot-files"
    @allRecords = [
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"heroku-sinatra-app.rb"),
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"root-app.rb"),
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"README.markdown"),
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"config.ru"),
               ]
    @records = []
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

