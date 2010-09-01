//
//  TFProgressBar.h
//  TFProgressBar
//
//  Created by Geoffrey Grosenbach on 6/12/09.
//  Copyright 2009 Topfunky Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TFProgressBar : NSProgressIndicator {
  NSString *labelText;
}

@property (nonatomic, assign) NSString *labelText;

@end
