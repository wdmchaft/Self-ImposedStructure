//
//  ChooseApp.m
//  Self-Imposed Structure
//
//  Created by Charles on 2/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "ChooseApp.h"


@implementation ChooseApp
@synthesize popUpRunningApps;
@synthesize buttonOk;
@synthesize buttonCancel;
@synthesize allApps;
@synthesize chosenApp;

- (IBAction) clickOk: (id) sender{
	//NSLog(@"index = %d allApps size = %d",popUpRunningApps.indexOfSelectedItem, [allApps count]);
	NSMenuItem *item = (NSMenuItem*) popUpRunningApps.selectedItem;
	chosenApp = [allApps objectAtIndex:item.tag];
	[super.window close];
	[NSApp stopModal];
}
- (IBAction) clickCancel: (id) sender{
	[super.window close];
[NSApp stopModal];
}

- (void) showWindow:(id)sender
{
	[super showWindow:sender];
	//[NSApp runModalForWindow:[super window]];
	chosenApp = nil;
	int x = 0;
	allApps = [[NSWorkspace sharedWorkspace]  runningApplications];
	for (NSRunningApplication *app in allApps){
		[popUpRunningApps addItemWithTitle:app.localizedName];
		[((NSMenuItem*)[popUpRunningApps lastItem]) setTag:x++];
	}
}
@end
