# -*- coding: utf-8 -*-
# FuzzyCell.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.
#
#
# A custom table cell implemented in Ruby.
#
# FuzzyCell#objectValue is the title. Other fields can be set in
# the tableView:willDisplayCell:forTableColumn:row: callback.

class FuzzyCell < NSCell

  # For a task-specific cell like this, use setRepresentedObject and
  # representedObject instead.
  attr_accessor :subtitle

  ICON_WIDTH = 30
  ICON_HEIGHT = 27

  ICON_PADDING_SIDE = 2

  # Vertical padding between the lines of text
  VERTICAL_PADDING = 5.0

  # Horizontal padding between icon and text
  HORIZONTAL_PADDING = 10.0

  TITLE_FONT_SIZE = 14.0

  SUBTITLE_VERTICAL_PADDING = 2.0
  SUBTITLE_FONT_SIZE = 10.0

  def drawInteriorWithFrame(theCellFrame, inView:theControlView)
    #     setDrawsBackground(true)
    #     setBackgroundColor(NSColor.greenColor)
    
    darkGrey = NSColor.colorWithCalibratedRed(0.3, green:0.3, blue:0.3, alpha:1.0)
    titleAttributes = {
      NSForegroundColorAttributeName => darkGrey,
      NSFontAttributeName            => NSFont.systemFontOfSize(TITLE_FONT_SIZE),
      NSParagraphStyleAttributeName  => paragraphStyle
    }
    if highlighted?
      titleAttributes[NSForegroundColorAttributeName] = NSColor.whiteColor
    end

    # Create strings for labels
    aTitle = NSMutableAttributedString.alloc.
      initWithString(self.objectValue, attributes:titleAttributes)
    titleEmphasisFont = NSFont.boldSystemFontOfSize(TITLE_FONT_SIZE)
    aTitle.beginEditing
    begin
      representedObject.matchedRanges.each do |range|
        unless highlighted?
          aTitle.addAttribute(NSForegroundColorAttributeName,
                              value:NSColor.blackColor,
                              range:range)
        end
        aTitle.addAttribute(NSFontAttributeName,
                            value:titleEmphasisFont,
                            range:range)
      end
    end
    aTitle.endEditing
    aTitleSize = aTitle.size

    aSubtitle = buildSubtitleString
    aSubtitleSize = aSubtitle.size

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
                          anInsetRect.origin.y + (anInsetRect.size.height/2) - (aCombinedHeight/2),
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


    # Draw the text
    aTitle.drawInRect(aTitleBox)
    aSubtitle.drawInRect(aSubtitleBox)
  end
  
  ##
  # TODO: Show icon for file as specified by Finder.
  
  def drawIconInRect(aRect)
    filetypeLabelAttributes = {
      NSForegroundColorAttributeName => NSColor.blackColor,
      NSFontAttributeName => NSFont.fontWithName("Futura-CondensedMedium", size:22)
    }
    filetypeLabelSize = filetypeSuffix.sizeWithAttributes(filetypeLabelAttributes)

    iconRect = NSMakeRect(aRect.origin.x,
                          aRect.origin.y + 8, # Should be specified elsewhere
                          filetypeLabelSize.width + (ICON_PADDING_SIDE*2),
                          ICON_HEIGHT)

    if highlighted?
      NSColor.colorWithCalibratedRed(0.7, green:0.7, blue:0.7, alpha:1.0).setFill
    else
      NSColor.colorWithCalibratedRed(0.5, green:0.5, blue:0.5, alpha:1.0).setFill
    end
    NSBezierPath.bezierPathWithRect(iconRect).fill

    filetypeLabelRect = NSInsetRect(iconRect, ICON_PADDING_SIDE, -1)
    filetypeLabelRect.size.width = filetypeLabelSize.width
    filetypeSuffix.drawInRect(filetypeLabelRect, withAttributes:filetypeLabelAttributes)

    return iconRect
  end

  ##
  # Returns "haml" for "a/b/c/d.haml"

  def filetypeSuffix
    File.extname(objectValue).sub(/^\./, '')[0..3].upcase
  end

  def buildSubtitleString
    subtitleAttributes = {
      NSForegroundColorAttributeName => NSColor.grayColor,
      NSFontAttributeName => NSFont.systemFontOfSize(SUBTITLE_FONT_SIZE),
      NSParagraphStyleAttributeName => paragraphStyle
    }
    if highlighted?
      subtitleAttributes[NSForegroundColorAttributeName] = NSColor.whiteColor
    end

    subtitleTemplate = "MODIFIED %s  GIT %s  CLASSES %s"
    displayDate = NSDate.stringForDisplayFromDate(representedObject.modifiedAt)

    subtitleString = self.representedObject.projectRoot ? subtitleTemplate % [
                                                                              displayDate,
                                                                              "++---",
                                                                              "ClassA • ClassB"
                                                                             ] : ""
    attrString = NSMutableAttributedString.alloc.
      initWithString(subtitleString,
                     attributes:subtitleAttributes)

    attrString.beginEditing
    begin
      subtitleLabelFont = NSFont.boldSystemFontOfSize(SUBTITLE_FONT_SIZE - 1)
      ["MODIFIED", "GIT", "CLASSES"].each do |label|
        if indexStart = subtitleString.index(/\b#{label}\b/)
          modifiedStringRange = NSMakeRange(indexStart, label.size)

          subtitleLabelColor = NSColor.colorWithCalibratedRed(0.7,
                                                              green:0.7,
                                                              blue:0.7,
                                                              alpha:1.0)
          attrString.addAttribute(NSForegroundColorAttributeName,
                                  value:subtitleLabelColor,
                                  range:modifiedStringRange)

          attrString.addAttribute(NSFontAttributeName,
                                  value:subtitleLabelFont,
                                  range:modifiedStringRange)
        end
      end
    end
    attrString.endEditing

    return attrString
  end

  def paragraphStyle
    return NSMutableParagraphStyle.new.
      setLineBreakMode(NSLineBreakByTruncatingTail)
  end

end
