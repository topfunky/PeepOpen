# FuzzyWindowController.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyWindowController < NSWindowController

  attr_accessor :tableViewController, :window

  def didSearchForString(sender)
    tableViewController.searchForString(sender.stringValue)
  end

  ##
  # Received when user hits Enter in search field or tabs out. Or clicks.
  #
  # TODO: Allow user to navigate results with arrows or mouse.
  
  def controlTextDidEndEditing(aNotification)
    record = tableViewController.records[0]
    # TODO: Reset search field and records for next use.
    system "open -a Emacs #{record.absFilePath}"
  end



  # -(BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector {
  #     BOOL result = NO;
  #     if (commandSelector == @selector(insertNewline:)) {
  #         // enter pressed
  #         result = YES;
  #     }
  #     else if(commandSelector == @selector(moveLeft:)) {
  #         // left arrow pressed
  #         result = YES;
  #     }
  #     else if(commandSelector == @selector(moveRight:)) {
  #         // rigth arrow pressed
  #         result = YES;
  #     }
  #     else if(commandSelector == @selector(moveUp:)) {
  #         // up arrow pressed
  #         result = YES;
  #     }
  #     else if(commandSelector == @selector(moveDown:)) {
  #         // down arrow pressed
  #         result = YES;
  #     }
  #     return result;
  # }

end

