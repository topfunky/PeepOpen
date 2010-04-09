# AppDelegate.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/20/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class AppDelegate

  attr_accessor :mainWindowController, :preferencesWindowController, :welcomeWindowController

  def applicationWillFinishLaunching(aNotification)
    registrationDefaults = {
      "editorApplicationName" => "TextMate",
      "maximumDocumentCount"  => 1000,
    }
    NSUserDefaults.standardUserDefaults.registerDefaults(registrationDefaults)
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

end

