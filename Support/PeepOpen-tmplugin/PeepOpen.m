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

- (void)showPeepOpen
{
	OakProjectController *project = NULL;
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/bin/env"];

	NSMutableArray *args = [NSMutableArray array];
	[args addObject:@"open"];
	[args addObject:@"-a"];
	[args addObject:@"PeepOpen"];
	
	for (NSWindow *w in [[NSApplication sharedApplication] orderedWindows]) {
		if ([[[w windowController] className] isEqualToString: @"OakProjectController"] &&
			[[w windowController] projectDirectory]) {
			project = [w windowController];
			break;
		}
	}
	
	if (project != NULL) {
		[args addObject:[project projectDirectory]];
		[task setArguments:args];
		[task launch];
	}
}

@end

@interface OakProjectController (PeepOpen) @end
@implementation OakProjectController (PeepOpen)
- (void)goToFile:(id)sender
{
	[[PeepOpen sharedInstance] showPeepOpen];
}
@end
