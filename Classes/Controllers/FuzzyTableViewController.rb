# FuzzyTableViewController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyTableViewController

  attr_accessor :tableView, :records

  def initialize
    # Dummy
    projectRoot = "~/tmp/heroku-sinatra-app"
    @records = [
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"heroku-sinatra-app.rb"),
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"root-app.rb"),
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"README.markdown"),
                FuzzyRecord.alloc.initWithProjectRoot(projectRoot,
                                                      filePath:"config.ru"),
               ]
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
    # TODO: Set cell attributes from @records[row]
    cell.subtitle = @records[row].projectRoot
  end

end

