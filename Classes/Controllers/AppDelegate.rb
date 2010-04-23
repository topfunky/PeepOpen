# AppDelegate.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/20/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class AppDelegate

  attr_accessor :fuzzyWindowController, :preferencesWindowController, :welcomeWindowController, :releaseNotesWindowController, :statusMenu

  def self.registrationDefaults
    {
      "editorApplicationName" => "TextMate",
      "maximumDocumentCount"  => 1000,
    }
  end

  def applicationWillFinishLaunching(aNotification)
    NSUserDefaults.standardUserDefaults.registerDefaults(AppDelegate.registrationDefaults)
  end

  def applicationDidFinishLaunching(aNotification)
    createStatusBarMenu

    # DEBUG
    #    unless NSUserDefaults.standardUserDefaults.boolForKey("hasBeenRunAtLeastOnce")
    showWelcome(self)
    #    end

    @fuzzyWindowController =
      windowControllerForNib("FuzzyWindow")
  end

  def createStatusBarMenu
    statusItem =
      NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)
    # NSSquareStatusItemLength
    statusItem.setMenu(statusMenu)
    statusItem.setHighlightMode(true)
    statusItem.setToolTip("PeepOpen")
    statusItem.setImage(NSImage.imageNamed("statusItemIcon.png"))
    # statusItem.setTitle("PeepOpen")
  end

  ##
  # Do something with the dropped file.

  def application(sender, openFile:path)
    fuzzyWindowController.tableViewController.loadFilesFromProjectRoot(path)
    fuzzyWindowController.show(self)
  end

  def showPreferences(sender)
    # TODO: If visible
    if fuzzyWindowController.respondsToSelector(:close)
      fuzzyWindowController.close
    end
    self.preferencesWindowController =
      windowControllerForNib("PreferencesWindow")
    preferencesWindowController.show(self)
  end

  def showWelcome(sender)
    self.welcomeWindowController =
      windowControllerForNib("WelcomeWindow")
    welcomeWindowController.show(self)
  end

  def showReleaseNotesWindow(sender)
    self.releaseNotesWindowController =
      windowControllerForNib("ReleaseNotesWindow")
    releaseNotesWindowController.show(self)
  end

  private

  # Given +nibName+, allocate and initialize the appropriate window
  # controller for the NIB.
  def windowControllerForNib nibName
    klass = Object.const_get "#{nibName}Controller"
    klass.alloc.initWithWindowNibName(nibName)
  end

end

