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
	NSString *projectDir;
	// If there is no window open we need to find the open window and extract
	// the projectDirectory from that
	if([[currentDocument valueForKey:@"filename"] length] == 0)
	{
		OakProjectController *project = NULL;
		for (NSWindow *w in [[NSApplication sharedApplication] orderedWindows]) {
			if ([[[w windowController] className] isEqualToString: @"OakProjectController"] &&
				[[w windowController] projectDirectory]) {
				project = [w windowController];
				break;
			}
		}
		if (project != NULL) {
			projectDir =  [project projectDirectory];
		}
	}
	else
	{
		projectDir = [currentDocument valueForKey:@"filename"];
	}
	NSString *projectURLString = [NSString stringWithFormat:@"peepopen://%@?editor=TextMate", projectDir];
	NSURL *url = [NSURL URLWithString:projectURLString];
	NSLog(@"OakprojectController (PeepOpen), sending url %@ to NSWorkspace", [url absoluteString]);
	[[NSWorkspace sharedWorkspace] openURL:url];
}
@end
