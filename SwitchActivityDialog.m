//
//  SwitchActivityDialog.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SwitchActivityDialog.h"
#import "Context.h"
#import "TaskList.h"
#import "Queues.h"

@implementation SwitchActivityDialog
@synthesize listsButton, okButton, cancelButton, availableActCombo, list, currentText, completeButton;

- (id<TaskList>) listForName: (NSString*)name
{
	Context *ctx = [Context sharedContext];
	NSArray *lists = [ctx getTrackedLists];
	for (id<TaskList> tl in lists){
		if ([[tl name] isEqualToString:name])
			return tl;
	}
	return nil;
}

- (void) clickItem: (id) sender
{
	NSString *selected = [[listsButton selectedItem] title];
	[availableActCombo setStringValue:@""];
	list = [self listForName:selected];
	if (list == nil){
		[availableActCombo setEnabled:NO];
	} else {
		[availableActCombo setEnabled:YES];
		[availableActCombo reloadData];
	}
}

- (void) initGuts
{
	Context *ctx = [Context sharedContext];
	NSString *currentStr =  [[ctx currentTask] objectForKey: @"name"];
	NSString *currentSrc =  [[ctx currentTask] objectForKey: @"source"];
	currentStr = (currentStr) ? currentStr : @"No Current Activity";
	[currentText setStringValue: currentStr];
	NSArray *lists = [ctx getTrackedLists];
	list = nil;
	
	for (id<TaskList> tl in lists){
		[listsButton addItemWithTitle:[tl name]];

		NSMenuItem *item = [listsButton itemWithTitle:[tl name]];
		[item setTarget:self];	
		[item setAction:@selector(clickItem:)];
		if ([currentSrc isEqualToString:[tl name]]){
			[listsButton selectItem:item];
			list = tl;
		}
	}
	if (!list){
		list = [lists objectAtIndex:0];
	}

	[availableActCombo reloadData];
//	NSDictionary *task = [ctx currentTask];
}

- (void) windowDidLoad
{
	[self initGuts];
}

- (void) showWindow: (id) sender
{
	[super showWindow: sender];
	[self initGuts];
}

- (void) clickLists: (id) sender
{
	BOOL disable = [[[listsButton selectedItem] title] isEqualToString:@"None Selected"] ;
	[availableActCombo setEnabled:!disable];
	if (disable){
		[availableActCombo setStringValue:@""];
	}

}

- (void) clickOk: (id) sender
{
	Context *ctx = [Context sharedContext];
	NSString *tName = [availableActCombo stringValue];
	NSString *srcName = [[listsButton selectedItem] title];
	ctx.currentTask = [NSDictionary dictionaryWithObjectsAndKeys:tName, @"name",
																	srcName, @"source",
																	@"default", @"project", nil];
	[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"New activity: %@",tName]];
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc postNotificationName:[Queues queueNameFor:WPA_ACTIVEQUEUE fromBase:[ctx queueName]]
					   object:nil 
					 userInfo: [NSDictionary dictionaryWithObjectsAndKeys:tName, @"name",
								srcName,@"source",nil]];
	[super.window close];
}

- (void) clickCancel: (id) sender
{
	[super.window close];
}
@end
