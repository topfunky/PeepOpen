# WelcomeWindowController.rb
# PeepOpen
#
# Created by Geoffrey Grosenbach on 4/9/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class WelcomeWindowController < NSWindowController

  attr_accessor :imageView

  def windowDidLoad
    # TODO: Configure styled text fields
  end

  def show(sender)
    NSApp.activateIgnoringOtherApps(true)
    window.center
    showWindow(sender)
    
    NSUserDefaults.standardUserDefaults.setBool(true,
                                                forKey:"hasBeenRunAtLeastOnce")
  end

  def close
    window.close
  end

  def showPreferences(sender)
    window.close
    NSApp.delegate.showPreferences(self)
  end

end

