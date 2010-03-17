# FuzzyTableViewController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyTableViewController

  attr_accessor :tableView, :records

  def initialize
    # Dummy
    # @records = 
  end

  # NSTableDataSource methods
  def numberOfRowsInTableView(tableView)
    self.updates.length
  end

  def tableView(tableView, objectValueForTableColumn:column, row:row)
    if row < updates.length
      case column.identifier
      when "user"
        # This is the title value for the custom cell
        return updates[row][:user]
      when "tweet"
        return updates[row][:tweet]
      end
    end
    nil
  end

  def tableView(tableView, willDisplayCell:cell, forTableColumn:column, row:row)
    case column.identifier
    when "user"
      # Subtitle and image values will be drawn together with the title from above
      cell.subtitle = updates[row][:created_at]
      cell.image    =
        NSImage.alloc.initByReferencingURL(NSURL.URLWithString(updates[row][:profile_image_url]))
    end
  end

end

