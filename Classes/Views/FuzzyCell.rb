# FuzzyCell.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.


##
# A custom table cell implemented in Ruby.
#
# FuzzyCell#objectValue is the title. Other fields can be set in
# the tableView:willDisplayCell:forTableColumn:row: callback.

class FuzzyCell < NSCell

  # For a task-specific cell like this, use setRepresentedObject and
  # representedObject instead.
  attr_accessor :subtitle, :image

  # Vertical padding between the lines of text
  VERTICAL_PADDING = 5.0

  # Horizontal padding between icon and text
  HORIZONTAL_PADDING = 10.0

  SUBTITLE_VERTICAL_PADDING = 2.0

  def drawInteriorWithFrame(theCellFrame, inView:theControlView)
#     setDrawsBackground(true)
#     setBackgroundColor(NSColor.greenColor)

    # Make attributes for our strings
    aParagraphStyle = NSMutableParagraphStyle.new
    aParagraphStyle.setLineBreakMode(NSLineBreakByTruncatingTail)

    aTitleAttributes = {
      NSForegroundColorAttributeName => NSColor.blackColor,
      NSFontAttributeName            => NSFont.systemFontOfSize(14.0),
      NSParagraphStyleAttributeName  => aParagraphStyle
    }

    aSubtitleAttributes = {
      NSForegroundColorAttributeName => NSColor.grayColor,
      NSFontAttributeName            => NSFont.boldSystemFontOfSize(10.0),
      NSParagraphStyleAttributeName  => aParagraphStyle
    }

    # Create strings for labels
    aTitle        = self.objectValue
    aTitleSize    = aTitle.sizeWithAttributes(aTitleAttributes)

    aSubtitle     = self.subtitle || ""
    aSubtitleSize = aSubtitle.sizeWithAttributes(aSubtitleAttributes)

    # Make the layout boxes for all of our elements - remember that
    # we're in a flipped coordinate system when setting the y-values

    # Icon box: center the icon vertically inside of the inset rect
    anInsetRect = NSInsetRect(theCellFrame, 10, 0)
    anIconBox = drawIconInRect(anInsetRect)

    # Make a box for our text
    # Place it next to the icon with horizontal padding
    # Size it horizontally to fill out the rest of the inset rect
    # Center it vertically inside of the inset rect
    aCombinedHeight = aTitleSize.height + aSubtitleSize.height + VERTICAL_PADDING

    aTextBox = NSMakeRect(anIconBox.origin.x + anIconBox.size.width + HORIZONTAL_PADDING,
                          anInsetRect.origin.y + anInsetRect.size.height * 0.5 - aCombinedHeight * 0.5,
                          anInsetRect.size.width - anIconBox.size.width - HORIZONTAL_PADDING,
                          aCombinedHeight)

    # Put the title in the top half and subtitle in the bottom half
    aTitleBox = NSMakeRect(aTextBox.origin.x,
                           aTextBox.origin.y + aTextBox.size.height * 0.5 - aTitleSize.height,
                           aTextBox.size.width,
                           aTitleSize.height)

    aSubtitleBox = NSMakeRect(aTextBox.origin.x,
                              aTextBox.origin.y + aTitleSize.height + SUBTITLE_VERTICAL_PADDING,
                              aTextBox.size.width,
                              aSubtitleSize.height)

    if self.highlighted?
      aTitleAttributes[NSForegroundColorAttributeName] = NSColor.whiteColor
      aSubtitleAttributes[NSForegroundColorAttributeName] = NSColor.whiteColor
    end

    # Draw the text
    aTitle.drawInRect(aTitleBox, withAttributes:aTitleAttributes)
    aSubtitle.drawInRect(aSubtitleBox, withAttributes:aSubtitleAttributes)
  end

  def drawIconInRect(aRect)
    #anIcon = self.image || NSImage.imageNamed("example")

    # Flip the icon because the entire cell has a flipped coordinate system
    #anIcon.setFlipped(true)

    # get the size of the icon for layout
    #anIconSize = anIcon.size

    iconRect = NSMakeRect(aRect.origin.x,
                          aRect.origin.y + aRect.size.height * 0.5 - 48 * 0.5,
                          48,
                          48)

    # Draw the icon
    #     anIcon.drawInRect(iconRect,
    #                       fromRect:NSZeroRect,
    #                       operation:NSCompositeSourceOver,
    #                       fraction:1.0)

    return iconRect
  end

end
