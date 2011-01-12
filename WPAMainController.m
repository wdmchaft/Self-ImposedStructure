//
//  WPAMainController.m
//  Nudge
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "WPAMainController.h"
#import "WPADelegate.h"
#include "ModulesTableData.h"
#include "Context.h"
#include "Columns.h"
#import "Module.h"
#import "TimerDialogController.h"
#import "TaskInfo.h"

@implementation WPAMainController
@synthesize  startButton, controls, taskComboBox, refreshButton, statusItem, statusMenu, statusTimer;

- (void)awakeFromNib
{
	WPADelegate *del = (WPADelegate*)[NSApplication sharedApplication].delegate;
	[del.window setReleasedWhenClosed:FALSE];
	Context *ctx = [Context sharedContext];


	[controls setSelectedSegment:ctx.startingState];
	if (ctx.startOnLoad){
		
		startButton.title = @"Stop";
		[del newRecord:ctx.startingState];

	} else {
		
		startButton.title = @"Start";
	}
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(statusHandler:)
				   name:@"org.ottoject.alarm" object:nil];
	[center addObserver: self selector:@selector(tasksChanged:)
				   name:@"org.ottoject.tasks" object:nil];
	
	[taskComboBox removeAllItems];
	NSArray *allTasks = [(WPADelegate*)[[NSApplication sharedApplication] delegate] getAllTasks];
	for(TaskInfo *info in allTasks){
		[taskComboBox addItemWithObjectValue:info]; 
	}
	if (ctx.currentTask){
		[taskComboBox setStringValue:[ctx.currentTask description]];
	}
	//[(WPADelegate*)[[NSApplication sharedApplication] delegate] registerTasksHandler:self];
	// start listening for commands
	NSDistributedNotificationCenter *dCenter = [NSDistributedNotificationCenter defaultCenter];
	// for the screensaver
	[dCenter addObserver:self selector:@selector(handleScreenSaverStart:) name:@"com.apple.screensaver.didlaunch" object:nil];
	[dCenter addObserver:self selector:@selector(handleScreenSaverStop:) name:@"com.apple.screensaver.didstop" object:nil];
	[taskComboBox setDelegate:self];
	[self enableUI: ctx.running];
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	statusItem.menu = statusMenu;
	//[statusItem setTitle:@"X"];
	[self initStatusMenu];
	[statusItem setHighlightMode:YES];
	[statusMenu  setAutoenablesItems:NO];
	if (ctx.startOnLoad){
		statusTimer = [NSTimer scheduledTimerWithTimeInterval:15 target: self selector:@selector(updateStatus:) userInfo:nil repeats:NO];
		NSLog(@"statusTimer = %@", statusTimer);
}
}

-(void) updateStatus: (NSTimer*) timer
{
	NSLog(@"updateStatus");
	[self initStatusMenu];
	statusTimer = [NSTimer scheduledTimerWithTimeInterval:15 target: self selector:@selector(updateStatus:) userInfo:nil repeats:NO];
	NSLog(@"statusTimer = %@", statusTimer);
}

-(void) initStatusMenu
{
	Context *ctx = [Context sharedContext];
	[[statusMenu itemWithTag:1] setState:NSOffState];
	[[statusMenu itemWithTag:2] setState:NSOffState];
	[[statusMenu itemWithTag:3] setState:NSOffState];
	[[statusMenu itemWithTag:4] setState:NSOffState];
	if (!ctx.running) {
		[statusItem setTitle:@"?"];
		[[statusMenu itemWithTag:1] setEnabled:NO];
		[[statusMenu itemWithTag:2] setEnabled:NO];
		[[statusMenu itemWithTag:3] setEnabled:NO];
		[[statusMenu itemWithTag:4] setEnabled:NO];
	} else {
		[[statusMenu itemWithTag:1] setEnabled:YES];
		[[statusMenu itemWithTag:2] setEnabled:YES];
		[[statusMenu itemWithTag:3] setEnabled:YES];
		[[statusMenu itemWithTag:4] setEnabled:YES];
		if (ctx.startingState == STATE_PUTZING) {
			[statusItem setTitle:@"P"];
			[[statusMenu itemWithTag:2] setState:NSOnState];
		}
		if (ctx.startingState == STATE_AWAY) {
			[statusItem setTitle:@"A"];
			[[statusMenu itemWithTag:3] setState:NSOnState];
		
		}
		if (ctx.startingState == STATE_THINKING) {
			[statusItem setTitle:@"W"];
			[[statusMenu itemWithTag:1] setState:NSOnState];
		}
		if (ctx.thinkTimer){
			NSTimeInterval interval = [[ctx.thinkTimer fireDate] timeIntervalSinceNow];
			NSUInteger mins = interval / 60;
			[statusItem setTitle: [NSString stringWithFormat:@"%d",mins] ];
			[[statusMenu itemWithTag:4] setState:NSOnState];
	}
	}
}

- (void) tasksChanged: (NSNotification*) notification
{
	[taskComboBox removeAllItems];
	Context *ctx = [Context sharedContext];
	ctx.tasksList = [(WPADelegate*)[[NSApplication sharedApplication] delegate] getAllTasks];
	for(TaskInfo *info in ctx.tasksList){
		[taskComboBox addItemWithObjectValue:info]; 
	}
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	Context *ctx = [Context sharedContext];
	NSComboBox *cb = taskComboBox;
	
	NSObject *selObj = [cb objectValueOfSelectedItem];
	if (selObj.class == NSString.class){
		ctx.currentTask = [TaskInfo new];
		ctx.currentTask.name = (NSString*) selObj;
	}
	ctx.currentTask = (TaskInfo*) selObj;
	if (ctx.currentTask == nil){
		NSLog(@"%@",cb.stringValue);
	}
	[ctx saveTask];
	
//	if ([ctx.currentTask isEqualToString:@"No Current Task"]){
//		ctx.currentTask = nil;
//	}
	
	// we changed jobs so write a new tracking record
	if (ctx.startingState == STATE_THINKING || ctx.startingState == STATE_THINKTIME){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:ctx.startingState];
	}
}
- (void) comboBoxSelectionWillChange:(NSNotification *)notification
{
}
- (void) comboBoxWillDismiss:(NSNotification *)notification
{
}
- (void) comboBoxWillPopUp:(NSNotification *)notification
{
}

- (void) enableUI: (BOOL) onOff
{
	[controls setEnabled:onOff];
	[taskComboBox setEnabled:onOff];
	[refreshButton setEnabled:onOff];
}

-(IBAction) clickStart: (NSButton*) sender {
	BOOL running = ([Context sharedContext].running);
	if (running){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] stop];
		startButton.title = @"Start";
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:STATE_OFF];
		[statusTimer invalidate];
	} else {
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] start];
		startButton.title = @"Stop";
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:[Context sharedContext].startingState];
		statusTimer = [NSTimer scheduledTimerWithTimeInterval:15 target: self selector:@selector(updateStatus:) userInfo:nil repeats:NO];
		NSLog(@"statusTimer = %@", statusTimer);
	}
	[self enableUI:!running];
	[self initStatusMenu];
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
	[self initStatusMenu];
}

-(IBAction) changeCombo: (id) sender {
	Context *ctx = [Context sharedContext];
	NSComboBox *cb = (NSComboBox*) sender;
	
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

-(void)handleScreenSaverStart:(NSNotification*) notification
{	
	
	if (![Context sharedContext].ignoreScreenSaver){
		NSLog(@"screen saver on");
		[self changeState:STATE_AWAY]; 
		[controls setSelectedSegment: STATE_AWAY];
	}
}

-(void)handleScreenSaverStop:(NSNotification*) notification
{	
	if (![Context sharedContext].ignoreScreenSaver){
		NSLog(@"screen saver off");
		[self changeState:STATE_PUTZING]; 
		[controls setSelectedSegment: STATE_PUTZING];
	}
}


@end
