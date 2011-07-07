//
//  AddActivityDialogController.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/31/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "AddActivityDialogController.h"
#import "Context.h"
#import "WPADelegate.h"
#import "WriteHandler.h"
#import "TaskList.h"
#import "Queues.h"


@implementation AddActivityDialogController
@synthesize okButton;
@synthesize cancelButton;
@synthesize taskField;
@synthesize busy;
@synthesize listsCombo;
@synthesize allLists;
@synthesize switchNowButton;
@synthesize taskList;

- (void) initCombo
{
	Context *ctx = [Context sharedContext];
	allLists = [ctx getTrackedLists];
	for(<TaskList> list in allLists){
		NSString *name = [list name];
		[listsCombo addItemWithTitle:name];
	}
}

- (void) windowDidLoad
{
	[busy setHidden:YES];
	[self initCombo];
	[switchNowButton setIntegerValue:1];
}

- (void) showWindow:(id)sender
{
	[self initCombo];
	[[super window] setLevel:NSFloatingWindowLevel];
    [[super window] setFrameAutosaveName:@"AddActivity"];
	[super showWindow:sender];
}

- (void) addDone
{
	Context *ctx = [Context sharedContext];
	[busy setHidden:YES];
	[busy stopAnimation:self];
	NSString *tName = [taskField stringValue];
	if ([switchNowButton integerValue]){
		ctx.currentTask = [NSDictionary dictionaryWithObjectsAndKeys:tName, @"name",
						   taskList.name, @"source",
						   @"default", @"project", nil];
		NSDistributedNotificationCenter *ndc = [NSDistributedNotificationCenter defaultCenter];
		NSString *aqName = [Queues queueNameFor:WPA_ACTIVEQUEUE fromBase:[ctx queueName]];
		NSString *uqName = [Queues queueNameFor:WPA_UPDATEQUEUE fromBase:[ctx queueName]];
		[ndc postNotificationName: aqName object:nil userInfo: ctx.currentTask];
		[ndc postNotificationName: uqName object:nil userInfo: ctx.currentTask];
		
		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"New activity: %@",tName]];
	} else {
		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"Added activity: %@", tName]];
	}
	[super.window close];
}

- (void)doAdd: (NSTimer*) timer 
{
	[taskList newTask: [taskField stringValue] completeHandler:self selector:@selector(addDone)];
}
	
- (IBAction) clickOK: (id) sender
{
	Context *ctx = [Context sharedContext];
	NSPopUpButton *lb = listsCombo;
	
	ctx.currentTask = nil;
	NSString *str = [lb titleOfSelectedItem];
	
	for (id<TaskList> tl  in allLists){
		if([[tl name] isEqualToString:str]){
			taskList  = tl;
			break;
		}
	}
	[busy setHidden:NO];
	[busy startAnimation:self];
	[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(doAdd:) userInfo:taskList repeats:NO ];

	//[addList newTask: [taskField stringValue] completeHandler:self selector:@selector(addDone)];

//	[ctx saveTask];
//	if (ctx.currentTask != nil){
//		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"Current activity: %@",[ctx.currentTask objectForKey:@"name"]]];
//	} else {
//		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"Current activity not set"]];
//	}
//	[super.window close];
}

- (IBAction) clickCancel: (id) sender
{
	[super.window close];

}


//}
@end
