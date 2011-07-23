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
@synthesize trackedButton;
@synthesize taskList;
@synthesize projectsPopup;

- (void) initCombos
{
	Context *ctx = [Context sharedContext];
	allLists = [ctx getTaskLists];
	for(id<TaskList> list in allLists){
		NSString *name = [list name];
		[listsCombo addItemWithTitle:name];
	}
	[listsCombo selectItemWithTitle:[ctx defaultSource]];
	WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication]delegate];
	NSArray *projNames = [del allActiveProjects];
	for (NSString *name in projNames) {
		[projectsPopup  addItemWithTitle:name];	 
	}
	[projectsPopup  selectItemWithTitle:@"Uncategorized"];
	id<TaskList> list = [[ctx instancesMap]objectForKey:[ctx defaultSource]];
	[switchNowButton setHidden: ![list tracked]];
	[switchNowButton setIntValue:0];
	[trackedButton setIntValue:[list tracked]];
	
}

- (void) windowDidLoad
{
	[busy setHidden:YES];
	[self initCombos];
	[switchNowButton setIntegerValue:1];
}

- (void) showWindow:(id)sender
{
	[self initCombos];
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
		[ctx setCurrentTask: [NSMutableDictionary dictionaryWithObjectsAndKeys:tName, @"name",
						   taskList.name, @"source",
						   @"default", @"project", nil]];
		NSDistributedNotificationCenter *ndc = [NSDistributedNotificationCenter defaultCenter];
		NSString *aqName = [Queues queueNameFor:WPA_ACTIVEQUEUE fromBase:[ctx queueName]];
		NSString *uqName = [Queues queueNameFor:WPA_UPDATEQUEUE fromBase:[ctx queueName]];
		[ndc postNotificationName: aqName object:nil userInfo: [ctx currentTask]];
		[ndc postNotificationName: uqName object:nil userInfo: [ctx currentTask]];
		
		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"New activity: %@",tName]];
	} else {
		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"Added activity: %@", tName]];
	}
	[super.window close];
}

- (void) clickList: (id) sender
{
	Context *ctx = [Context sharedContext];
	NSString *listName = [listsCombo titleOfSelectedItem];
	id<TaskList> list = [[ctx instancesMap]objectForKey:listName];
	[switchNowButton setHidden: ![list tracked]];
	[switchNowButton setIntValue:0];
	[trackedButton setIntValue:[list tracked]];	
}

- (void)doAdd: (NSTimer*) timer 
{
	[taskList newTask: [taskField stringValue] completeHandler:self selector:@selector(addDone)];
}
	
- (IBAction) clickOK: (id) sender
{
	Context *ctx = [Context sharedContext];
	NSPopUpButton *lb = listsCombo;
	
	[ctx setCurrentTask: nil ];
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
//	if ([ctx currentTask] != nil){
//		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"Current activity: %@",[[ctx currentTask] objectForKey:@"name"]]];
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
