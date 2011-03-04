//
//  PeepOpen.h
//  PeepOpen
//
//  Created by Pieter Noordhuis on 6/2/10.
//

#import <Cocoa/Cocoa.h>
#import "TextMate.h"

@protocol TMPlugInController
- (float)version;
@end

@interface PeepOpen : NSObject
{
}
+ (id)sharedInstance;
- (id)initWithPlugInController:(id <TMPlugInController>)controller;
@end
