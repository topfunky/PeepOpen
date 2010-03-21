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
  
  # Received when user hits Enter in search field.
  def controlTextDidEndEditing(aNotification)
    NSLog "ended editing"
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

