//
//  AddActivityDialogController.m
//  WorkPlayAway
//
//  Created by Charles on 1/31/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "AddActivityDialogController.h"
#import "TaskInfo.h"
#import "Context.h"
#import "WPADelegate.h"

@implementation AddActivityDialogController
@synthesize okButton;
@synthesize cancelButton;
@synthesize activityCombo;

- (void) initCombo
{
	Context *ctx = [Context sharedContext];
	
	[activityCombo removeAllItems];
	NSArray *allTasks = [ctx getTasks];
	for(TaskInfo *info in allTasks){
		[activityCombo addItemWithObjectValue:info]; 
	}
	if (ctx.currentTask){
		[activityCombo setStringValue:[ctx.currentTask description]];
	}	
}

- (void) windowDidLoad
{
	[self initCombo];
}

- (void) showWindow:(id)sender
{
	[self initCombo];
	[[super window] setLevel:NSFloatingWindowLevel];
	[super showWindow:sender];
}

- (IBAction) clickOK: (id) sender
{
	Context *ctx = [Context sharedContext];
	NSComboBox *cb = activityCombo;
	
	ctx.currentTask = [cb objectValueOfSelectedItem];
	
	// if we get don't get the default or empty then it is "adhoc" task  (with no source)
	
	if (ctx.currentTask == nil){
		if (![cb.stringValue isEqualToString:@"No Current Task"] && [cb.stringValue length] > 0) {
			TaskInfo *newTI = [TaskInfo	new];
			newTI.name = cb.stringValue;
			ctx.currentTask = newTI;
		}
	}
	[ctx saveTask];
	
	// we changed jobs so write a new tracking record
	if (ctx.currentState == WPASTATE_THINKING || ctx.currentState == WPASTATE_THINKTIME){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:ctx.currentState];
	}
	[ctx.growlManager growlThis:[NSString stringWithFormat: @"New Activity: %@",ctx.currentTask.name]];

	[super.window close];
}

- (IBAction) clickCancel: (id) sender
{
	[super.window close];

}
@end
