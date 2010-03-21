# AppDelegate.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/20/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class AppDelegate
  
  attr_accessor :mainWindowController
  
  ##
  # Do something with the dropped file.
  
  def application(sender, openFile:path)
    mainWindowController.tableViewController.loadFilesFromProjectRoot(path)
    mainWindowController.activate
  end

end

