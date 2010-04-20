# AppDelegate.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/20/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class AppDelegate

  attr_accessor :mainWindowController, :preferencesWindowController, :welcomeWindowController

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
    unless NSUserDefaults.standardUserDefaults.boolForKey("hasBeenRunAtLeastOnce")
      showWelcome(self)
    end
  end

  ##
  # Do something with the dropped file.

  def application(sender, openFile:path)
    mainWindowController.tableViewController.loadFilesFromProjectRoot(path)
    mainWindowController.activate
  end

  def showPreferences(sender)
    mainWindowController.close
    preferencesWindowController.show(self)
  end

  def showWelcome(sender)
    welcomeWindowController.show(self)
  end

#   # Snippet
#   def showReleaseNotesWindow sender
#     self.releaseNotesWindowController = windowControllerForNib "ReleaseNotesWindow"
#     releaseNotesWindowController.showWindow self
#   end
#   private
#   # Given +nibName+, allocate and initialize the appropriate window
#   # controller for the NIB.
#   def windowControllerForNib nibName
#     klass = Object.const_get "TF#{nibName}Controller"
#     klass.alloc.initWithWindowNibName nibName
#   end

end

