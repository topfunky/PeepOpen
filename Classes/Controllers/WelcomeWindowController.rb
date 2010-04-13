# WelcomeWindowController.rb
# PeepOpen
#
# Created by Geoffrey Grosenbach on 4/9/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class WelcomeWindowController < NSWindowController

  attr_accessor :preferencesWindowController

  def show(sender)
    window.center
    showWindow(sender)
    NSUserDefaults.standardUserDefaults.setBool(true,
                                                forKey:"hasBeenRunAtLeastOnce")
  end

  def showPreferences(sender)
    preferencesWindowController.show(self)
    close
  end

end

