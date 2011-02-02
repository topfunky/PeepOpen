//
//  PeepOpen.m
//  PeepOpen
//
//  Created by Pieter Noordhuis on 6/2/10.
//

#import "PeepOpen.h"

@implementation PeepOpen
static PeepOpen *po;
+ (id)sharedInstance
{
	return po;
}

- (id)initWithPlugInController:(id <TMPlugInController>)controller
{
	self = [self init];
	po = self;
	return self;
}

@end

@interface OakProjectController (PeepOpen) @end
@implementation OakProjectController (PeepOpen)
- (void)goToFile:(id)sender
{
	NSString *projectFile = [NSString stringWithFormat:@"peepopen://%@?editor=TextMate", [currentDocument valueForKey:@"filename"]];
	NSURL *url = [NSURL URLWithString:projectFile];
	NSLog(@"OakprojectController (PeepOpen), sending url %@ to NSWorkspace", [url absoluteString]);
	[[NSWorkspace sharedWorkspace] openURL:url];
}
@end
