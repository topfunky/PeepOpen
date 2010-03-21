# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyWindowController < NSWindowController
  
  attr_accessor :tableViewController, :window
  
  # TODO: Respond to ENTER in text field
  
  def didSearchForString(sender)
    tableViewController.searchForString(sender.stringValue)
  end

end

