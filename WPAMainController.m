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
#import "SummaryHUDControl.h"

@implementation WPAMainController
@synthesize  startButton, controls, taskComboBox, refreshButton, statusItem, statusMenu, statusTimer, myWindow;
@synthesize hudWindow, refreshManager, growlDelegate, thinkTimer;

- (void)awakeFromNib
{
	[myWindow setDelegate: self];
	WPADelegate *del = (WPADelegate*)[NSApplication sharedApplication].delegate;
	[del.window setReleasedWhenClosed:FALSE];
	Context *ctx = [Context sharedContext];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector:@selector(statusHandler:)
				   name:@"org.ottoject.alarm" object:nil];
	[center addObserver: self selector:@selector(tasksChanged:)
				   name:@"org.ottoject.tasks" object:nil];
	
	[taskComboBox removeAllItems];
	NSArray *allTasks = [ctx getTasks];
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
	}
}

-(void) updateStatus: (NSTimer*) timer
{
	[self initStatusMenu];
	statusTimer = [NSTimer scheduledTimerWithTimeInterval:15 target: self selector:@selector(updateStatus:) userInfo:nil repeats:NO];
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
		if (ctx.currentState == WPASTATE_FREE) {
			[statusItem setTitle:@"P"];
			[[statusMenu itemWithTag:2] setState:NSOnState];
		}
		if (ctx.currentState == WPASTATE_AWAY) {
			[statusItem setTitle:@"A"];
			[[statusMenu itemWithTag:3] setState:NSOnState];
		
		}
		if (ctx.thinkTimer){
			NSTimeInterval interval = [[ctx.thinkTimer fireDate] timeIntervalSinceNow];
			NSUInteger mins = ceil(interval / 60);
			[statusItem setTitle: [NSString stringWithFormat:@"%d",mins] ];
			[[statusMenu itemWithTag:4] setState:NSOnState];
		} else if (ctx.currentState == WPASTATE_THINKING) {
			[statusItem setTitle:@"W"];
			[[statusMenu itemWithTag:1] setState:NSOnState];
		}

	}
}

- (void) tasksChanged: (NSNotification*) notification
{
	[taskComboBox removeAllItems];
	Context *ctx = [Context sharedContext];
	ctx.tasksList = [ctx getTasks];
	for(TaskInfo *info in ctx.tasksList){
		[taskComboBox addItemWithObjectValue:info]; 
	}
}

//- (void)comboBoxSelectionDidChange:(NSNotification *)notification
//{
//	Context *ctx = [Context sharedContext];
//	NSComboBox *cb = taskComboBox;
//	
//	NSObject *selObj = [cb objectValueOfSelectedItem];
//	if (selObj.class == NSString.class){
//		ctx.currentTask = [TaskInfo new];
//		ctx.currentTask.name = (NSString*) selObj;
//	}
//	ctx.currentTask = (TaskInfo*) selObj;
//	if (ctx.currentTask == nil){
//		NSLog(@"%@",cb.stringValue);
//	}
//	[ctx saveTask];
//
//	// we changed jobs so write a new tracking record
//	if (ctx.currentState == WPASTATE_THINKING || ctx.currentState == WPASTATE_THINKTIME){
//		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:ctx.currentState];
//	}
//}
//- (void) comboBoxSelectionWillChange:(NSNotification *)notification
//{
//}
//- (void) comboBoxWillDismiss:(NSNotification *)notification
//{
//}
//- (void) comboBoxWillPopUp:(NSNotification *)notification
//{
//}

- (void) enableUI: (BOOL) onOff
{
	[controls setEnabled:onOff];
	[taskComboBox setEnabled:onOff];
	[refreshButton setEnabled:onOff];
}

-(IBAction) clickStart: (NSButton*) sender {
	[self running:YES];
}
-(IBAction) clickStop: (NSButton*) sender {
	[self running:NO];
}

- (void) running: (BOOL) on
{
	Context *ctx = [Context sharedContext];
	WPAStateType newState = ctx.previousState;
	if (on == NO){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] stop];
		startButton.title = @"Start";
		[startButton setAction: @selector(clickStart:)];
		[growlDelegate stop];
		newState = WPASTATE_OFF;
		[statusTimer invalidate];
	} else {
		startButton.title = @"Stop";
		[startButton setAction: @selector(clickStop:)];
		statusTimer = [NSTimer scheduledTimerWithTimeInterval:15 target: self selector:@selector(updateStatus:) userInfo:nil repeats:NO];
		growlDelegate = [GrowlDelegate new];
		newState = WPASTATE_FREE;
	}
	ctx.running = on;
//	[self enableUI:ctx.running];
//	[self initStatusMenu];
	[self changeState:newState];
}

- (IBAction) clickTimed: (id) sender
{
	[self changeState: WPASTATE_THINKTIME];
	[controls setSelectedSegment: WPASTATE_THINKTIME];	
}

- (IBAction) clickWork: (id) sender
{
	[self changeState: WPASTATE_THINKING];
	[controls setSelectedSegment: WPASTATE_THINKING];	

}

- (IBAction) clickPlay: (id) sender
{
	[self changeState: WPASTATE_FREE];
	[controls setSelectedSegment: WPASTATE_FREE];	
}

- (IBAction) clickAway: (id) sender
{
	[self changeState: WPASTATE_AWAY];
	[controls setSelectedSegment: WPASTATE_AWAY];
}

- (IBAction) clickControls: (id) sender
{
	int newState = controls.selectedSegment;
//	if (newState == WPASTATE_THINKTIME){
//		TimerDialogController *tdc = [[TimerDialogController alloc] initWithWindowNibName:@"TimerDialog"];
//		NSWindow *tdcWindow = [tdc window];
//		[tdcWindow orderFrontRegardless];
//		[NSApp runModalForWindow: tdcWindow];
//
//	}
	[self changeState:newState];
}

// decide if we need to display a summary screen - this should be shown if 
// 1 the preferences say show it at all
// 2 the user is back from power off or sleep
// 3 and he was away for a time longer than the preferred threshold
//
- (BOOL) needsSummary
{
	Context *ctx = [Context sharedContext];
	if (ctx.showSummary == YES){
		if (ctx.currentState!= WPASTATE_FREE && ctx.currentState != WPASTATE_SUMMARY) {
			NSDate *lastChange = ctx.lastStateChange;
			NSTimeInterval timeAway = [[NSDate date] timeIntervalSinceDate:lastChange];
			if (timeAway > ctx.timeAwayThreshold)
				return YES;
		}
	}
	return NO;
}

// decide if we need to go right back to work
// 1 the preferences say we want that option 
// 2 and we were *in fact* previously working
// 3 and the time period we were away is SHORTER than the preferred threshold
//
- (BOOL) shouldGoBackToWork
{
	Context *ctx = [Context sharedContext];
	if (ctx.autoBackToWork && (ctx.currentState == WPASTATE_THINKTIME || ctx.previousState == WPASTATE_THINKING)){
		if (ctx.previousState == WPASTATE_AWAY || ctx.currentState == WPASTATE_OFF) {
			NSDate *lastChange = ctx.lastStateChange;
			NSTimeInterval timeAway = [[NSDate date] timeIntervalSinceDate:lastChange];
			if (timeAway < ctx.brbThreshold)
				return TRUE;
		}	
	}
	return NO;
}

// If a summary is necessary then control hands off to SummaryHUDController for the duration
// Essentially we are in a pause until the data for the summary is collected, presented to the user 
// and finally dismissed by the user (and again, all under control of SummaryHUDController)
//
- (void) showSummaryScreen
{
	NSLog(@"Show Summary screne here");
	Context *ctx = [Context sharedContext];
	SummaryHUDControl *shc = [[SummaryHUDControl alloc]initWithWindowNibName:@"SummaryHUD"];
	hudWindow = shc.window;
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(summaryClosed:) 
												 name:NSWindowWillCloseNotification 
											   object:shc.window];

	ctx.currentState = WPASTATE_SUMMARY;
	[shc processSummary];
	
}

- (void) summaryClosed:(NSNotification*) notification{
	NSLog(@"summaryClosed");
	[[NSNotificationCenter defaultCenter] removeObserver:self  
												 name:NSWindowWillCloseNotification 
											   object:nil];
	refreshManager = [[RefreshManager alloc]initWithHandler:growlDelegate];
	[refreshManager startWithRefresh:NO];
	[controls setSelectedSegment: WPASTATE_FREE];
	[self changeState:WPASTATE_FREE];
	//[Context sharedContext].currentState= WPASTATE_FREE;
}


- (void) changeState: (WPAStateType) newState
{
	Context *ctx = [Context sharedContext];
	//
	// were we just away for a (longish) while?
	if (newState == WPASTATE_FREE)
	{
		if ([self needsSummary]){
			[self showSummaryScreen];
			return;
		}
		if ([self shouldGoBackToWork]) {
			newState = WPASTATE_THINKING;
		} else {
			[ctx freeModules];
		}

	}
	if (newState == WPASTATE_THINKTIME){
		TimerDialogController *tdc = [[TimerDialogController alloc] initWithWindowNibName:@"TimerDialog"];
		NSWindow *tdcWindow = [tdc window];
		[tdcWindow orderFrontRegardless];
		[NSApp runModalForWindow: tdcWindow];
		newState = WPASTATE_THINKING;
	} else if (thinkTimer) {
		[thinkTimer invalidate];
		thinkTimer = nil;
	}
	if (newState == WPASTATE_THINKING){
		[ctx busyModules];
	}
	if (newState == WPASTATE_AWAY){
		[ctx awayModules];
	}
	
	ctx.currentState = newState == WPASTATE_THINKTIME ? WPASTATE_THINKING : newState;
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:newState];
	[ctx saveDefaults];
	[self initStatusMenu];
	[self enableUI:(newState != WPASTATE_OFF)];
	if (refreshManager == nil && newState != WPASTATE_OFF){
		refreshManager = [[RefreshManager alloc]initWithHandler:growlDelegate];
		[refreshManager startWithRefresh:YES];
	}
	if (newState == WPASTATE_OFF){
		[refreshManager stop];
		refreshManager = nil;
	}
}

-(IBAction) changeCombo: (id) sender {
	NSLog(@"changeCombo");
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
	if (ctx.currentState == WPASTATE_THINKING || ctx.currentState == WPASTATE_THINKTIME){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:ctx.currentState];
	}
}


-(void) statusHandler: (NSNotification*) notification
{
	controls.selectedSegment = WPASTATE_FREE; // WPASTATE_FREE
}

- (void) clickRefresh:(id)sender
{
	[(WPADelegate*)[[NSApplication sharedApplication] delegate]refreshTasks];
}

-(void)handleScreenSaverStart:(NSNotification*) notification
{	
	
	if (![Context sharedContext].ignoreScreenSaver){
		[controls setSelectedSegment: WPASTATE_AWAY];
	}
}

-(void)handleScreenSaverStop:(NSNotification*) notification
{	
	if (![Context sharedContext].ignoreScreenSaver){
		[self changeState:WPASTATE_FREE]; 
		[controls setSelectedSegment: WPASTATE_FREE];
	}
}


@end
