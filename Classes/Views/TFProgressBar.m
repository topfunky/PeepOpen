//
//  TFProgressBar.m
//  TFProgressBar
//
//  Created by Geoffrey Grosenbach on 6/12/09.
//  Copyright 2009 Topfunky Corporation. All rights reserved.
//

#import "TFProgressBar.h"

#define TFProgressBarHeight        20.0
#define TFProgressBarWidth        200.0
#define TFProgressBarStrokeWidth    2.0
#define TFProgressBarOuterInset     2.0
#define TFProgressBarInnerBarInset  1.0
#define TFProgressBarInnerBarHeight 14.0

@interface TFProgressBar (PrivateMethods)
- (void) drawOutline;
- (void) drawDeterminateInnerBar;
- (void) drawIndeterminateInnerBar;
- (void) drawLabel;
- (void) alignPathToPixel:(NSBezierPath *)thePath;
@end

@implementation TFProgressBar

@synthesize labelText;

- (id) initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    labelText = @"";
  }
  return self;
}

- (void)setDoubleValue:(double)doubleValue {
  [super setDoubleValue:doubleValue];
  [self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)rect {
  // Background color
  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
  NSRectFill(rect);

  [self drawOutline];
  // TODO: Optionally draw indeterminate bar
  [self drawDeterminateInnerBar];
  [self drawLabel];
}

- (void) drawOutline {
  // Outline
  NSBezierPath * path = [NSBezierPath bezierPath];
  [path setLineWidth:TFProgressBarStrokeWidth];
  [path appendBezierPathWithRoundedRect:NSMakeRect(self.frame.size.width / 2.0 - TFProgressBarWidth / 2.0,
                                                   (self.frame.size.height / 2.0 - TFProgressBarHeight / 2.0),
                                                   TFProgressBarWidth,
                                                   TFProgressBarHeight)
                                xRadius:TFProgressBarHeight/2.0
                                yRadius:TFProgressBarHeight/2.0];

  [self alignPathToPixel:path];
  [[NSColor whiteColor] set];    
  [path stroke];
}

- (void) drawLabel
{
  NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [paragraphStyle setAlignment:NSCenterTextAlignment];
  
  [labelText drawInRect:NSMakeRect(self.frame.size.width / 2.0 - TFProgressBarWidth / 2.0,
                                   (self.frame.size.height / 2.0 - TFProgressBarHeight / 2.0) + TFProgressBarHeight * 1.5,
                                   TFProgressBarWidth,
                                   TFProgressBarHeight)    
         withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, 
                         [NSFont systemFontOfSize:10.0f], NSFontAttributeName, 
                         paragraphStyle, NSParagraphStyleAttributeName, nil]];
}

- (void) drawDeterminateInnerBar {
  // Return immediately if minValue
  if (self.doubleValue == self.minValue)
    return;

  NSUInteger maxBarWidth = TFProgressBarWidth -
    TFProgressBarHeight;

  NSPoint startPoint = {  (self.frame.size.width / 2.0 - TFProgressBarWidth / 2.0) + TFProgressBarHeight / 2.0,
                          (self.frame.size.height / 2.0 - TFProgressBarInnerBarHeight / 2.0) };
  float actualBarWidth = 0.0;
  if (self.doubleValue == self.maxValue) {
    actualBarWidth = maxBarWidth;
  } else {
    actualBarWidth = maxBarWidth * (self.doubleValue / self.maxValue);
  }

  // Top line
  NSBezierPath * path = [NSBezierPath bezierPath];

  // Left Endcap
  NSPoint leftEndcapCenterPoint = startPoint;
  leftEndcapCenterPoint.y = (self.frame.size.height / 2.0);
  [path appendBezierPathWithArcWithCenter:leftEndcapCenterPoint
                                   radius:TFProgressBarInnerBarHeight / 2.0
                               startAngle:90
                                 endAngle:270];

  // Draw rectangle if larger than minValue, plus left half-circle.
  [path appendBezierPathWithRect:NSMakeRect(startPoint.x, startPoint.y, actualBarWidth, TFProgressBarInnerBarHeight)];

  // Draw right half-circle if maxValue
  if (self.doubleValue == self.maxValue) {
    // Rounded end for maxValue
    NSPoint rightEndcapCenterPoint = NSMakePoint(0,0);
    rightEndcapCenterPoint.x = (self.frame.size.width / 2.0 - TFProgressBarWidth / 2.0) + TFProgressBarWidth - TFProgressBarHeight / 2.0;
    rightEndcapCenterPoint.y = (self.frame.size.height / 2.0);
    [path appendBezierPathWithArcWithCenter:rightEndcapCenterPoint
                                     radius:TFProgressBarInnerBarHeight / 2.0
                                 startAngle:270
                                   endAngle:90];
  }

  [self alignPathToPixel:path];
  [[NSColor whiteColor] set];
  [path fill];
}

// Put path center in center of pixel so it draws whole pixels instead of anti-aliasing them.
- (void) alignPathToPixel:(NSBezierPath *)thePath
{
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform translateXBy:0.5 yBy:0.5];
  [thePath transformUsingAffineTransform:transform];  
}

@end
