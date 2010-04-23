# ReleaseNotesWindowController.rb
# PeepOpen
#
# Created by Geoffrey Grosenbach on 4/21/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.


class ReleaseNotesWindowController < NSWindowController

  attr_accessor :webView

  def show(sender)
    NSApp.activateIgnoringOtherApps(true)
    window.center
    showWindow(sender)
    
    # TODO: Load from local resource in bundle
    feedURLString = NSBundle.mainBundle.infoDictionary.objectForKey("SUFeedURL")
    releaseNotesURLString = feedURLString.gsub("appcast.xml", "release_notes.html")
    releaseNotesURL = NSURL.URLWithString(releaseNotesURLString)
    webView.mainFrame.loadRequest(NSURLRequest.requestWithURL(releaseNotesURL))
  end

end
