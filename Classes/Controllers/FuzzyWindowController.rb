# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyWindowController < NSWindowController

  attr_accessor :tableViewController, :searchField, :statusLabel, :projectRoot

  def show(sender)
    NSApp.activateIgnoringOtherApps(true)
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

  def loadFilesFromProjectRoot(theProjectRoot)
    self.projectRoot = theProjectRoot
    tableViewController.loadFilesFromProjectRoot(theProjectRoot)
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
      unless handleKeyWithModifier
        handleCancel
      end
      return true
      
    end
    # Other Events: :"pageDown:"
    return false
  end

  def handleKeyWithModifier
    modifierFlags = NSApp.currentEvent.modifierFlags
    if ((modifierFlags & NSCommandKeyMask) == NSCommandKeyMask)
      case NSApp.currentEvent.charactersIgnoringModifiers
      when /r/
        FuzzyRecord.flushCache(projectRoot)
        tableViewController.reset
        loadFilesFromProjectRoot(projectRoot)
        didSearchForString(searchField)
        return true
      end
    elsif ((modifierFlags & NSControlKeyMask) == NSControlKeyMask)
      # NSLog "Ctrl is down"
    end
    false
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

