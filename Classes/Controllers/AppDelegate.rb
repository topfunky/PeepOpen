# AppDelegate.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/20/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class AppDelegate

  attr_accessor :mainWindowController, :preferencesWindow

  def applicationWillFinishLaunching(aNotification)
    registrationDefaults = {
      "editorApplicationName" => "TextMate",
      "maximumDocumentCount"  => 1000,
    }
    NSUserDefaults.standardUserDefaults.registerDefaults(registrationDefaults)
  end

  ##
  # Do something with the dropped file.

  def application(sender, openFile:path)
    mainWindowController.tableViewController.loadFilesFromProjectRoot(path)
    mainWindowController.activate

    #     applicationNames = NSWorkspace.sharedWorkspace.launchedApplications.map {|a|
    #       a.objectForKey("NSApplicationName")
    #     }
    #     NSLog "Apps: #{applicationNames}"
  end

  def showPreferences(sender)
    mainWindowController.close
    preferencesWindow.makeKeyAndOrderFront(self)
    preferencesWindow.center
  end

end

