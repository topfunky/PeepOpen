# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

require 'NSWindowControllerHelper'

class FuzzyWindowController < NSWindowController
  
  include Constants

  attr_accessor :tableViewController, :searchField, :statusLabel, :projectRoot
  attr_accessor :progressBar, :settingsMenuButton

  include NSWindowControllerHelper

  def windowDidLoad
    setWindowFrameAutosaveName("com.topfunky.PeepOpen.FuzzyWindowController.frame")
    statusLabel.stringValue = ""

    self.progressBar = TFProgressBar.alloc.initWithFrame(window.contentView.frame)
    self.progressBar.labelText = ""
    if NSUserDefaults.standardUserDefaults.boolForKey("useCoreAnimation")
      progressBar.setWantsLayer(true)
    end
    
    settingsMenuButton.setMenu(NSApp.delegate.statusMenu)
  end

  def showStatusMenu(sender)
    NSMenu.popUpContextMenu(NSApp.delegate.statusMenu, withEvent:NSApp.currentEvent, forView:window.contentView)
  end

  def show(sender)
    NSApp.activateIgnoringOtherApps(true)

    showWindow self
    tableViewController.selectFirstRow
    searchField.setStringValue("")
    window.makeFirstResponder(searchField)
  end

  def close
    window.close
  end

  def loadFilesFromProjectRoot(theProjectRoot)
    timer = NSTimer.scheduledTimerWithTimeInterval( 0.25,
                                     target: self,
                                   selector: :"checkProgress:",
                                   userInfo: nil,
                                    repeats: true)

    statusLabel.stringValue = "Loading..."
    progressBar.labelText = "Reading files..."
    
    # FuzzyRecord.discoverProjectRootForDirectoryOrFile returns the projectRoot and a flag
    self.projectRoot, projectRootFoundFlag = FuzzyRecord.discoverProjectRootForDirectoryOrFile(theProjectRoot)

    @tableViewController.reset

    if nil == FuzzyRecord.cachedRecordsForProjectRoot(self.projectRoot)
      progressBar.frame = window.contentView.frame
      window.contentView.addSubview(progressBar)
      progressBar.maxValue = NSUserDefaults.standardUserDefaults.doubleForKey("maximumDocumentCount")
      updateProgressBarWithDoubleValue(10)
    end

    tableViewController.loadFilesFromProjectRoot(self.projectRoot)

    unless projectRootFoundFlag
      # timer.invalidate
      # statusLabel.stringValue = "Project not found."
      runWarningAlertWithMessage("Couldn't Find a Project",
      informativeText:"#{theProjectRoot} wasn't part of a Git, Ruby, Xcode, or other project. See the Help menu or the Project Root Pattern preference in the Advanced tab for configuration options.\n\nShowing files from\n#{self.projectRoot}")
    end

  end


  def didFinishLoadingFilesFromProjectRoot
      progressBar.removeFromSuperview()
      didSearchForString(searchField)
  end

  def updateProgressBarWithDoubleValue(theDoubleValue)
    progressBar.doubleValue = theDoubleValue
    if (theDoubleValue % 100) == 0
      progressBar.labelText = "Reading #{theDoubleValue} files..."
    end
  end

  def refreshFileList(sender)
    FuzzyRecord.flushCache(projectRoot)
    # Give the notifications a little time to catch up
    sleep(0.25)
    tableViewController.reset
    loadFilesFromProjectRoot(projectRoot)
  end


  ##
  # Called when text is entered into the search field.

  def didSearchForString(sender)
    tableViewController.searchForString(sender.stringValue)
  end

  def updateStatusLabel
    statusLabel.stringValue = "%i records" % [tableViewController.records.size]
  end

  ##
  # Handle Enter, arrows, and other events in search field.
  #
  # Returns true if this class handles it, false otherwise.

  def control(control, textView:textView, doCommandBySelector:commandSelector)
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
      # COMMAND key
      case NSApp.currentEvent.charactersIgnoringModifiers
      when /r/
        # Refresh
          @tableViewController.queue.cancelAllOperations
          refreshFileList(self)
        return true
      when /v/
        # Paste
        searchField.stringValue = NSPasteboard.generalPasteboard.stringForType(NSPasteboardTypeString)
        didSearchForString(searchField)
        return true
      when /c/
        # Copy
        pasteboard = NSPasteboard.generalPasteboard
        pasteboard.declareTypes([NSPasteboardTypeString], owner:nil)
        pasteboard.setString(searchField.stringValue, forType:NSPasteboardTypeString)
        return true
      when /x/
        # Cut
        pasteboard = NSPasteboard.generalPasteboard
        pasteboard.declareTypes([NSPasteboardTypeString], owner:nil)
        pasteboard.setString(searchField.stringValue, forType:NSPasteboardTypeString)
        searchField.stringValue = ""
        didSearchForString(searchField)
        return true
      when /a/
        # Select all
        window.makeFirstResponder(searchField)
        #[theTextView setSelectedRange: NSMakeRange(0,0)];
        return true
      end
    elsif ((modifierFlags & NSControlKeyMask) == NSControlKeyMask)
      # Control key
      case NSApp.currentEvent.charactersIgnoringModifiers
      when /m/ # C-m is alternate for ENTER
        handleNewline
        return true
      end
    end
    false
  end

  def handleNewline
    if tableViewController.handleRowClick(tableViewController.tableView.selectedRow)
      searchField.setStringValue("")
      window.close
    else
      runWarningAlertWithMessage("No Files Were Found", informativeText:"Please activate PeepOpen again from a code project.")
    end
  end

  def handleCancel
    editorApplicationName = NSApp.delegate.sessionConfig.editorName
    editorApplicationName =
      NSUserDefaults.standardUserDefaults.stringForKey('editorApplicationName') if editorApplicationName.empty?

    NSWorkspace.sharedWorkspace.launchApplication(editorApplicationName)

    tableViewController.reset
    window.close
  end
  
  def checkProgress(timer)
    if @tableViewController.queue.operations.size == 0
      timer.invalidate
      @tableViewController.createAllRecords
      FuzzyRecord.setCacheRecords(@tableViewController.allRecords, forProjectRoot:projectRoot)
      didFinishLoadingFilesFromProjectRoot
    end
  end

end

