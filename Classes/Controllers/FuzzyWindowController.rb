# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

require 'NSWindowControllerHelper'

class FuzzyWindowController < NSWindowController

  attr_accessor :tableViewController, :searchField, :statusLabel, :projectRoot
  attr_accessor :progressBar

  include NSWindowControllerHelper

  def windowDidLoad
    @queue = Dispatch::Queue.new('com.topfunky.PeepOpen.FuzzyWindowController')

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector:"receivedProgressNotification:",
                                                   name:"fuzzyRecordProgress",
                                                   object:nil)

    setWindowFrameAutosaveName("com.topfunky.PeepOpen.FuzzyWindowController.frame")
    
    statusLabel.stringValue = ""
    
    self.progressBar = TFProgressBar.alloc.initWithFrame(window.contentView.frame)
    if NSUserDefaults.standardUserDefaults.boolForKey("useCoreAnimation")
      progressBar.setWantsLayer(true)
    end
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
    statusLabel.stringValue = "Loading..."
    
    self.projectRoot = FuzzyRecord.discoverProjectRootForDirectoryOrFile(theProjectRoot)
    if nil == FuzzyRecord.cachedRecordsForProjectRoot(self.projectRoot)
      progressBar.frame = window.contentView.frame
      window.contentView.addSubview(progressBar)
      progressBar.maxValue = NSUserDefaults.standardUserDefaults.doubleForKey("maximumDocumentCount")
      updateProgressBarWithDoubleValue(10)
    end

    self.performSelectorInBackground("loadFilesFromProjectRootAsync:",
                                     withObject:self.projectRoot)
  rescue FuzzyRecord::ProjectRootNotFoundError => e
    statusLabel.stringValue = "Project not found."
    runWarningAlertWithMessage("Couldn't Find a Project",
                               informativeText:"#{theProjectRoot} wasn't part of a Git, Ruby, Xcode, or other project. See the Help menu or the Project Root Pattern preference in the Advanced tab for configuration options.")
  end

  def loadFilesFromProjectRootAsync(theProjectRoot)
    @queue.sync do
      tableViewController.loadFilesFromProjectRoot(self.projectRoot)
    end
    if tableViewController.allRecords.length == 0
      runWarningAlertWithMessage("Couldn't Find Files",
                                 informativeText:"Try another directory or see the Project Root Pattern preference in the Advanced tab.")
    end

    self.performSelectorOnMainThread("didFinishLoadingFilesFromProjectRoot",
                                     withObject:nil,
                                     waitUntilDone:false)
  end

  def didFinishLoadingFilesFromProjectRoot
    progressBar.removeFromSuperview()

    didSearchForString(searchField)
    updateStatusLabel
  end

  def receivedProgressNotification(theNotification)
    updateProgressBarWithDoubleValue(theNotification.object.length)
  end

  def updateProgressBarWithDoubleValue(theDoubleValue)
    progressBar.doubleValue = theDoubleValue
  end

  def refreshFileList(sender)
    FuzzyRecord.flushCache(projectRoot)
    tableViewController.reset
    loadFilesFromProjectRoot(projectRoot)
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

  def handleNewline
    if tableViewController.handleRowClick(tableViewController.tableView.selectedRow)
      searchField.setStringValue("")
      window.close
    else
      runWarningAlertWithMessage("No Text Editor Found", informativeText:"Please choose a text editor in PeepOpen preferences.")
    end
  end

  def handleCancel
    editorApplicationName =
      NSUserDefaults.standardUserDefaults.stringForKey('editorApplicationName')
    NSWorkspace.sharedWorkspace.launchApplication(editorApplicationName)
    
    tableViewController.reset
    window.close
  end

end

