# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyWindowController < NSWindowController

  attr_accessor :tableViewController, :searchField, :statusLabel, :projectRoot

  def windowDidLoad
    setWindowFrameAutosaveName("com.topfunky.PeepOpen.FuzzyWindowController.frame")
  end

  def show(sender)
    NSApp.activateIgnoringOtherApps(true)
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
    self.projectRoot = FuzzyRecord.discoverProjectRootForDirectoryOrFile(theProjectRoot)
    tableViewController.loadFilesFromProjectRoot(self.projectRoot)
    if tableViewController.allRecords.length == 0
      NSLog "No files found"
    end
    # TODO: Catch FuzzyRecord::ProjectRootNotFoundError
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

    when :"cancelOperation:"
      # Triggered when ESC is hit but search field has text in it
      if (searchField.stringValue != "")
        searchField.setStringValue("")
        didSearchForString(searchField)
      else
        handleCancel
      end
      return true

    when :"cancel:"
      # Triggered when ESC is hit with blank search field
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
        refreshFileList(self)
        return true
      end
    elsif ((modifierFlags & NSControlKeyMask) == NSControlKeyMask)
      # NSLog "Ctrl is down"
    end
    false
  end

  def refreshFileList(sender)
    FuzzyRecord.flushCache(projectRoot)
    tableViewController.reset
    loadFilesFromProjectRoot(projectRoot)
    didSearchForString(searchField)
  end

  def handleNewline
    if tableViewController.handleRowClick(tableViewController.tableView.selectedRow)
      window.close
    else
      runWarningAlertWithMessage("No Text Editor Found", informativeText:"Please choose a text editor in PeepOpen preferences.")
    end
  end

  def handleCancel
    editorApplicationName =
      NSUserDefaults.standardUserDefaults.stringForKey('editorApplicationName')
    NSWorkspace.sharedWorkspace.launchApplication(editorApplicationName)
    window.close
  end

  private


  ##
  # Shamefully copied from PreferencesWindowController.rb.
  #
  # Need to refactor into a subclass of NSWindowController.
  
  def runWarningAlertWithMessage(theMessage, informativeText:theInformativeText)
    alert = NSAlert.alloc.init
    alert.addButtonWithTitle("OK")
    alert.setMessageText(theMessage)
    alert.setInformativeText(theInformativeText)
    alert.setAlertStyle(NSWarningAlertStyle)
    alert.beginSheetModalForWindow(window,
                                   modalDelegate:self,
                                   didEndSelector:nil,
                                   contextInfo:nil)
  end


end

