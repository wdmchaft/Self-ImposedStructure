//
//  WPAMainController.m
//  Nudge
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WPAMainController.h"
#import "WPADelegate.h"
#include "ModulesTableData.h"
#include "Context.h"
#include "Columns.h"
#import "Module.h"
#import "TimerDialogController.h"
//#import "UKLoginItemRegistry.h"

@implementation WPAMainController
@synthesize  startButton, controls, taskComboBox, refreshButton;

- (void)awakeFromNib
{
	Context *ctx = [Context sharedContext];
	

	[controls setSelectedSegment:ctx.startingState];
	if (ctx.startOnLoad){
		
		startButton.title = @"Stop";
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:ctx.startingState];

	} else {
		
		startButton.title = @"Start";
	}
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(statusHandler:)
				   name:@"org.ottoject.alarm" object:nil];

	[taskComboBox removeAllItems];
	NSArray *allTasks = [(WPADelegate*)[[NSApplication sharedApplication] delegate] getAllTasks];
	for(NSString *taskName in allTasks){
		[taskComboBox addItemWithObjectValue:taskName]; 
	}
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] registerTasksHandler:self];
}

- (void) tasksChanged
{
	[taskComboBox removeAllItems];
	NSArray *allTasks = [(WPADelegate*)[[NSApplication sharedApplication] delegate] getAllTasks];
	for(NSString *taskName in allTasks){
		[taskComboBox addItemWithObjectValue:taskName]; 
	}
}

-(IBAction) clickStart: (NSButton*) sender {
	if ([Context sharedContext].running){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] stop];
		startButton.title = @"Start";
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:STATE_OFF];
} else {
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] start];
		startButton.title = @"Stop";
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:[Context sharedContext].startingState];
	}
}

- (IBAction) clickTimed: (id) sender
{
	[self changeState: STATE_THINKTIME];
	[controls setSelectedSegment: STATE_THINKTIME];	

}

- (IBAction) clickWork: (id) sender
{
	[self changeState: STATE_THINKING];
	[controls setSelectedSegment: STATE_THINKING];	

}

- (IBAction) clickPlay: (id) sender
{
	[self changeState: STATE_PUTZING];
	[controls setSelectedSegment: STATE_PUTZING];	
}

- (IBAction) clickAway: (id) sender
{
	[self changeState: STATE_AWAY];
	[controls setSelectedSegment: STATE_AWAY];
}

- (IBAction) clickControls: (id) sender
{
	int state = controls.selectedSegment;
	if (state == STATE_THINKTIME){
		TimerDialogController *tdc = [[TimerDialogController alloc] initWithWindowNibName:@"TimerDialog"];
		NSWindow *tdcWindow = [tdc window];
		
		[NSApp runModalForWindow: tdcWindow];

	}
	Context *ctx = [Context sharedContext];
	if (ctx.running){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] setState:state];
	}

	ctx.startingState = state == STATE_THINKTIME ? STATE_THINKING : state;
	[ctx saveDefaults];
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:state];
		
}

- (void) changeState: (int) state
{
	if (state == STATE_THINKTIME){
		TimerDialogController *tdc = [[TimerDialogController alloc] initWithWindowNibName:@"TimerDialog"];
		NSWindow *tdcWindow = [tdc window];
		
		[NSApp runModalForWindow: tdcWindow];
		
	}
	Context *ctx = [Context sharedContext];
	if (ctx.running){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] setState:state];
	}
	
	ctx.startingState = state == STATE_THINKTIME ? STATE_THINKING : state;
	[ctx saveDefaults];
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:state];
}

-(IBAction) changeCombo: (id) sender {
	Context *ctx = [Context sharedContext];
	NSComboBox *cb = (NSComboBox*) sender;
	
	ctx.currentTask = [cb stringValue];
	if ([ctx.currentTask isEqualToString:@"No Current Task"]){
		ctx.currentTask = nil;
	}
	
	// we changed jobs so write a new tracking record
	if (ctx.startingState == STATE_THINKING || ctx.startingState == STATE_THINKTIME){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:ctx.startingState];
	}
}


-(void) statusHandler: (NSNotification*) notification
{
	controls.selectedSegment = 0;
}

- (void) clickRefresh:(id)sender
{
	[(WPADelegate*)[[NSApplication sharedApplication] delegate]refreshTasks];
}
@end
