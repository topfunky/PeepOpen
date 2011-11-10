# -*- CODING: utf-8 -*-
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

  ICON_HEIGHT = 27
  ICON_WIDTH  = 50 # Distance to right edge of right-aligned icon

  ICON_PADDING_SIDE = 2.0

  # Vertical padding between the lines of text
  VERTICAL_PADDING = 5.0

  # Horizontal padding between icon and text
  HORIZONTAL_PADDING = 10.0

  TITLE_FONT_SIZE = 14.0

  SUBTITLE_VERTICAL_PADDING = 2.0
  SUBTITLE_FONT_SIZE = 10.0

  def drawInteriorWithFrame(theCellFrame, inView:theControlView)
    darkGrey = NSColor.colorWithCalibratedRed(0.3, green:0.3, blue:0.3, alpha:1.0)
    titleAttributes = {
      NSForegroundColorAttributeName => darkGrey,
      NSFontAttributeName            => NSFont.systemFontOfSize(TITLE_FONT_SIZE),
      NSParagraphStyleAttributeName  => paragraphStyle,
      NSShadowAttributeName          => whiteShadow
    }
    if darkBackground?
      titleAttributes[NSForegroundColorAttributeName] = NSColor.whiteColor
      titleAttributes.delete(NSShadowAttributeName)
    end

    # Create strings for labels
    aTitle = NSMutableAttributedString.alloc.
      initWithString(self.objectValue, attributes:titleAttributes)
    titleEmphasisFont = NSFont.boldSystemFontOfSize(TITLE_FONT_SIZE)
    if representedObject.matchedRanges
      aTitle.beginEditing
      begin
        representedObject.matchedRanges.each do |range|
          aTitle.addAttribute(NSForegroundColorAttributeName,
                              value:(darkBackground? ? NSColor.whiteColor : NSColor.blackColor),
                              range:range)
          aTitle.addAttribute(NSFontAttributeName,
                              value:titleEmphasisFont,
                              range:range)
        end
      end
      aTitle.endEditing
    end
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
                           aTextBox.size.width - HORIZONTAL_PADDING,
                           aTitleSize.height)

    aSubtitleBox = NSMakeRect(aTextBox.origin.x,
                              aTextBox.origin.y + aTitleSize.height + SUBTITLE_VERTICAL_PADDING,
                              aTextBox.size.width - HORIZONTAL_PADDING,
                              aSubtitleSize.height)

    # Draw the text
    aTitle.drawInRect(aTitleBox)
    aSubtitle.drawInRect(aSubtitleBox)

    # TODO: Draw 1px white on top if this is the top cell in the table.
    drawLowerCellShadowInFrame(theCellFrame)
  end

  ##
  # Subtle 1px shadow at bottom of cell.

  def drawLowerCellShadowInFrame(aFrame)
    path = NSBezierPath.bezierPath
    path.setLineWidth(1.0)
    path.moveToPoint([aFrame.origin.x - 2.0,
                      aFrame.origin.y + aFrame.size.height - 1.0])
    path.lineToPoint([aFrame.origin.x + aFrame.size.width + 2.0,
                      aFrame.origin.y + aFrame.size.height - 1.0])

    lineColor = NSColor.colorWithCalibratedRed(0.8,
                                               green:0.8,
                                               blue:0.8,
                                               alpha:1.0).setStroke

    if highlighted?
      lineColor = NSColor.colorWithCalibratedRed(0.7,
                                                 green:0.7,
                                                 blue:0.7,
                                                 alpha:1.0).setStroke
    end

    transform = NSAffineTransform.transform
    transform.translateXBy(0.5, yBy:0.5)
    path.transformUsingAffineTransform(transform)

    path.stroke
  end

  ##
  # Shows letters of file extension as a graphic.

  def drawIconInRect(aRect)
    if !NSUserDefaults.standardUserDefaults.boolForKey("showCellIcon")
      return NSMakeRect(-2.0, 0, 0, 0)
    end

    filetypeLabelFont = NSFont.fontWithName("Futura-CondensedMedium", size:22) ||
      NSFont.systemFontOfSize(18)

    filetypeLabelAttributes = {
      NSForegroundColorAttributeName => NSColor.colorWithCalibratedRed(0.85,
                                                                       green:0.85,
                                                                       blue:0.85,
                                                                       alpha:1.0),
      NSFontAttributeName => filetypeLabelFont
    }
    if highlighted? || darkBackground?
      filetypeLabelAttributes[NSForegroundColorAttributeName] = NSColor.whiteColor
    end
    filetypeLabelSize = filetypeSuffix.sizeWithAttributes(filetypeLabelAttributes)

    iconBoxWidth = filetypeLabelSize.width.ceil + (ICON_PADDING_SIDE*2)
    iconRect = NSMakeRect(ICON_WIDTH - iconBoxWidth,
                          aRect.origin.y + 7, # Should be a constant
                          iconBoxWidth + 1,
                          ICON_HEIGHT)

    boxGradentStartColor = NSColor.colorWithCalibratedRed(0.5,
                                                          green:0.5,
                                                          blue:0.5,
                                                          alpha:1.0)
    boxGradentEndColor = NSColor.colorWithCalibratedRed(0.3,
                                                        green:0.3,
                                                        blue:0.3,
                                                        alpha:1.0)

    boxPath = NSBezierPath.bezierPathWithRoundedRect(iconRect,
                                                     xRadius:2.0,
                                                     yRadius:2.0)
    gradient =
      NSGradient.alloc.initWithStartingColor(boxGradentStartColor,
                                             endingColor:boxGradentEndColor)
    gradient.drawInBezierPath(boxPath, angle:50.0)

    filetypeLabelRect = NSInsetRect(iconRect, ICON_PADDING_SIDE + 1, -1)
    filetypeLabelRect.size.width = filetypeLabelSize.width
    filetypeSuffix.drawInRect(filetypeLabelRect, withAttributes:filetypeLabelAttributes)

    return iconRect
  end

  ##
  # Returns "haml" for "a/b/c/d.haml"

  def filetypeSuffix
    ext = File.extname(objectValue).sub(/^\./, '')[0..3].upcase
    ext.length > 0 ? ext : "•"
  end

  def buildSubtitleString
    subtitleAttributes = {
      NSForegroundColorAttributeName => NSColor.grayColor,
      NSFontAttributeName => NSFont.systemFontOfSize(SUBTITLE_FONT_SIZE),
      NSParagraphStyleAttributeName => paragraphStyle
    }
    if darkBackground?
      subtitleAttributes[NSForegroundColorAttributeName] = NSColor.whiteColor
    end

    displayDate = NSDate.stringForDisplayFromDate(representedObject.modifiedAt)
    subtitleString = ["#{displayDate}"]
    scmStatus = representedObject.scmStatus
    if scmStatus && scmStatus.size > 0
      subtitleString << "GIT #{scmStatus}"
    end
    if ENV["TF_VISUAL_DEBUG"]
      subtitleString << "SCORE #{representedObject.matchScore}"
      if representedObject.matchesOnFilenameScore && representedObject.matchesOnFilenameScore > 0
        subtitleString << "FILEMATCH true"
      end
      if representedObject.longestMatch && representedObject.longestMatch > 0
        subtitleString << "LONGEST #{representedObject.longestMatch}"
      end
    end
    subtitleString = subtitleString.join("  ")
    attrString = NSMutableAttributedString.alloc.
      initWithString(subtitleString,
                     attributes:subtitleAttributes)

    if darkBackground?
      return attrString
    end

    attrString.beginEditing
    begin
      subtitleLabelFont = NSFont.boldSystemFontOfSize(SUBTITLE_FONT_SIZE - 1)
      # TODO: Make string highlighting into own method.
      # TODO: Take hash of regex, highlightedColor, color
      #       {
      #         /GIT (\++)/ => {
      #           :indexStart => "+",
      #           NSForegroundColorAttributeName => "",
      #           :highlighted => {
      #             NSForegroundColorAttributeName => ""
      #           },
      #           NSFontAttributeName => ""
      #         },
      #         /\b(GIT)\b/ => {
      #           ...
      #         }
      #       }

      # TODO: Cleanup
      if matchObj = subtitleString.match(/GIT (\++)/)
        indexStart = subtitleString.index("+")
        modifiedStringRange = NSMakeRange(indexStart,
                                          matchObj.captures.first.size)

        gitPlusLabelColor = NSColor.colorWithCalibratedRed(0,
                                                           green:0.6,
                                                           blue:0,
                                                           alpha:1.0)
        attrString.addAttribute(NSForegroundColorAttributeName,
                                value:gitPlusLabelColor,
                                range:modifiedStringRange)
      end
      if matchObj = subtitleString.match(/(-+)/)
        indexStart = subtitleString.index("-")
        modifiedStringRange = NSMakeRange(indexStart,
                                          matchObj.captures.first.size)

        gitPlusLabelColor = NSColor.colorWithCalibratedRed(0.6,
                                                           green:0,
                                                           blue:0,
                                                           alpha:1.0)
        attrString.addAttribute(NSForegroundColorAttributeName,
                                value:gitPlusLabelColor,
                                range:modifiedStringRange)
      end

      ["GIT"].each do |label|
        if indexStart = subtitleString.index(/\b#{label}\b/)
          modifiedStringRange = NSMakeRange(indexStart, label.size)

          subtitleLabelColor = NSColor.colorWithCalibratedRed(0.7,
                                                              green:0.7,
                                                              blue:0.7,
                                                              alpha:1.0)
          if highlighted?
            darkerGreyColor = NSColor.colorWithCalibratedRed(0.6,
                                                             green:0.6,
                                                             blue:0.6,
                                                             alpha:1.0)
            subtitleLabelColor = darkerGreyColor
          end
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

  ##
  # Background is dark when selected with the mouse.

  def darkBackground?
    self.backgroundStyle == NSBackgroundStyleDark
  end

  def paragraphStyle
    return NSMutableParagraphStyle.new.
      setLineBreakMode(NSLineBreakByTruncatingMiddle)
  end

  # TODO: Put in own class
  def whiteShadow
    return @whiteShadow if @whiteShadow
    @whiteShadow = NSShadow.new
    @whiteShadow.setShadowColor(NSColor.colorWithDeviceWhite(1.0, alpha:0.9))
    @whiteShadow.setShadowOffset(NSMakeSize(0.0, -1.0))
    @whiteShadow.setShadowBlurRadius(0.0)
  end

end
