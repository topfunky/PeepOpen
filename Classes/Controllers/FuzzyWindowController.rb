# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyWindowController < NSWindowController

  attr_accessor :tableViewController, :searchField, :statusLabel

  def show(sender)
    window.center
    showWindow self
    tableViewController.selectFirstRow
    searchField.setStringValue("")
    window.makeFirstResponder(searchField)
    updateStatusLabel
  end

  def close
    window.close
  end

  ##
  # Called when text is entered into the search field.

  def didSearchForString(sender)
    tableViewController.searchForString(sender.stringValue)
    updateStatusLabel
  end

  def updateStatusLabel
    statusLabel.stringValue = "%i records" % [tableViewController.records.size]
  end

  ##
  # Handle Enter, arrows, and other events in search field.
  #
  # Returns true if this class handles it, false otherwise.

  def control(control, textView:textView, doCommandBySelector:commandSelector)
    # NSLog "cmd #{commandSelector}"
    case commandSelector
    when :"insertTab:"
      # Tab should not be used...arrow keys work automatically when in
      # search field.
      tableViewController.selectNextRow
      return true

    when :"insertNewline:"
      handleNewline
      return true

    when :"moveUp:"
      tableViewController.selectPreviousRow
      return true

    when :"moveDown:"
      tableViewController.selectNextRow
      return true

    when :"cancel:"
      handleCancel
      return true

    when :"noop:"
      # Emacs-like C-g
      handleCancel
      return true

      # when :"pageDown:"

    end
    return false
  end

  def handleNewline
    tableViewController.handleRowClick(tableViewController.tableView.selectedRow)
    window.close
  end

  def handleCancel
    editorApplicationName =
      NSUserDefaults.standardUserDefaults.stringForKey('editorApplicationName')
    NSWorkspace.sharedWorkspace.launchApplication(editorApplicationName)
    window.close
  end

end

