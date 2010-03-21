# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyWindowController < NSWindowController

  attr_accessor :tableViewController, :window, :searchField

  def activate
    showWindow self
    tableViewController.selectFirstRow
    searchField.setStringValue("")
    window.makeFirstResponder(searchField)
  end

  def didSearchForString(sender)
    tableViewController.searchForString(sender.stringValue)
  end

  ##
  # Handle Enter, arrows, and other events in search field.
  #
  # Returns true if this class handles it, false otherwise.

  def control(control, textView:textView, doCommandBySelector:commandSelector)
    case commandSelector
    when :"insertNewline:"
      handleNewline
      return true

    when :"moveUp:"
      tableViewController.selectPreviousRow
      return true

    when :"moveDown:"
      tableViewController.selectNextRow
      return true

    end
    return false
  end

  def handleNewline
    selectedRowIndex = tableViewController.tableView.selectedRow
    selectedRowIndex = 0 if selectedRowIndex == -1
    if record = tableViewController.records[selectedRowIndex]
      # TODO: Reset search field and records for next use.
      system "open -a Emacs #{record.absFilePath}"
    end
  end

end

