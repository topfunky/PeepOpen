# WelcomeWindowController.rb
# PeepOpen
#
# Created by Geoffrey Grosenbach on 4/9/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class AboutWindowController < NSWindowController

  attr_accessor :versionLabel

  # def windowDidLoad
  # end

  def show(sender)
    NSApp.activateIgnoringOtherApps(true)
    window.center
    showWindow(sender)
    populateFields
  end

  def close
    window.close
  end

  def populateFields
    bundleVersion = NSBundle.mainBundle.infoDictionary.objectForKey("CFBundleVersion")
    versionLabel.stringValue = "Version #{bundleVersion}"
  end

  def visitWebsite(sender)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString("http://peepcode.com/products/peepopen?r=peepcode-peepopen-app"))
  end

end

