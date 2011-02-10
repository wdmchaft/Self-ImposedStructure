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
#import "TimerDialogController.h"
#import "TaskInfo.h"
#import "SummaryHUDControl.h"
#import "AddActivityDialogController.h"
#import "Menu.h"

@implementation WPAMainController
@synthesize  startButton, controls, taskComboBox, refreshButton, statusItem, statusMenu, statusTimer, myWindow;
@synthesize hudWindow, refreshManager, thinkTimer, siView, totalsManager, prefsWindow, statsWindow, addActivityWindow;
- (void)awakeFromNib
{
	[myWindow setDelegate: self];
	WPADelegate *del = (WPADelegate*)[NSApplication sharedApplication].delegate;
	[del.window setReleasedWhenClosed:FALSE];
	
	// if nothing is configured lets run preferences
	Context *ctx = [Context sharedContext];
	if ([ctx.instancesMap count] == 0){
		[self clickPreferences:self];
	}
	
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
	totalsManager = [TotalsManager new];
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	statusItem.menu = statusMenu;
	//[statusItem setTitle:@"X"];
	[self buildStatusMenu];
	[statusItem setHighlightMode:YES];
	[statusMenu  setAutoenablesItems:NO];
//	if (ctx.startOnLoad){
		statusTimer = [NSTimer scheduledTimerWithTimeInterval:totalsManager.interval
													   target: self 
													 selector:@selector(updateStatus:) 
													 userInfo:nil 
													  repeats:NO];
//	}
	[self setupHotKey];
}

-(void) updateStatus: (NSTimer*) timer
{
	Context *ctx = [Context sharedContext];
	[self buildStatusMenu];
	statusTimer = [NSTimer scheduledTimerWithTimeInterval:totalsManager.interval 
												   target: self 
												 selector:@selector(updateStatus:) 
												 userInfo:nil 
												  repeats:NO];
	[totalsManager addInterval:ctx.currentState];
}

-(void) enableStatusMenu: (BOOL) yesNo
{
	NSArray *items = [statusMenu itemArray];
	for (NSMenuItem *item in items){
		if (item.tag == MENU_WORK || item.tag == MENU_TIMED || item.tag == MENU_FREE || item.tag == MENU_AWAY){
			[item setEnabled:yesNo];
		}
	}
}

-(void) buildStatusMenu
{
	Context *ctx = [Context sharedContext];
	NSRect rect = {{0,0},{22.0,22.0}};
	if (siView == nil) {
		siView = [[StatusIconView alloc]initWithFrame:rect];
		siView.statusItem = statusItem;
		siView.statusMenu = statusMenu;
	}
	siView.timer = thinkTimer;
	siView.goal = ctx.dailyGoal;
	siView.current = totalsManager.workToday;
	siView.state = ctx.currentState;
	[statusItem setView:siView];
	
	[[statusMenu itemWithTag:MENU_WORK] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_AWAY] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_FREE] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_TIMED] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_STOPSTART] setTitle:@"Start"];
	[[statusMenu itemWithTag:MENU_STOPSTART] setAction:@selector(clickStart:)];
	if (!ctx.running || ctx.currentState == WPASTATE_SUMMARY) {
		//[statusItem setTitle:@"?"];
		[[statusMenu itemWithTag:MENU_WORK] setEnabled:NO];
		[[statusMenu itemWithTag:MENU_AWAY] setEnabled:NO];
		[[statusMenu itemWithTag:MENU_FREE] setEnabled:NO];
		[[statusMenu itemWithTag:MENU_TIMED] setEnabled:NO];
	} else {
		[[statusMenu itemWithTag:MENU_WORK] setEnabled:YES];
		[[statusMenu itemWithTag:MENU_AWAY] setEnabled:YES];
		[[statusMenu itemWithTag:MENU_FREE] setEnabled:YES];
		[[statusMenu itemWithTag:MENU_TIMED] setEnabled:YES];
		if (ctx.currentState == WPASTATE_FREE) {
	//		[statusItem setTitle:@"P"];
			[[statusMenu itemWithTag:MENU_FREE] setState:NSOnState];
		}
		if (ctx.currentState == WPASTATE_AWAY) {
	//		[statusItem setTitle:@"A"];
			[[statusMenu itemWithTag:MENU_AWAY] setState:NSOnState];
		}
		if (thinkTimer){
			NSTimeInterval interval = [[thinkTimer fireDate] timeIntervalSinceNow];
			if (interval < 0){
				[thinkTimer invalidate];
				thinkTimer = nil;
				return;
			}
			[[statusMenu itemWithTag:MENU_TIMED] setState:NSOnState];
		} 
		else if (ctx.currentState == WPASTATE_THINKING) {
			[[statusMenu itemWithTag:MENU_WORK] setState:NSOnState];
		}
		NSMenuItem *aMenuItem = [statusMenu itemWithTag:5];
		[self fillActivities:aMenuItem.submenu];
		[[statusMenu itemWithTag:MENU_STOPSTART] setTitle:@"Stop"];
		[[statusMenu itemWithTag:MENU_STOPSTART] setAction:@selector(clickStop:)];
	}
}

- (void) fillActivities: (NSMenu*) menu
{
	[menu setAutoenablesItems:NO];
	Context *ctx = [Context sharedContext];
	if (ctx.tasksList == nil){
		ctx.tasksList = [ctx getTasks];
	}
	// clear anything out first
	while ([[menu itemArray] count] > 2) {
		NSMenuItem *mi = [menu itemAtIndex:2];
		[menu removeItem:mi];
	}
	for(TaskInfo *info in ctx.tasksList){
		NSMenuItem *mi = [[NSMenuItem alloc]initWithTitle:info.description 
												   action:@selector(newActivity:)
											keyEquivalent:@""];
		[mi setTarget:self];
		[menu addItem:mi]; 
		mi.state = NSOffState;
		[mi setEnabled:YES];
		[mi setRepresentedObject:info];
		if (ctx.currentTask && [ctx.currentTask isEqual:info]){
			mi.state = NSOnState;
	}
	}
}

- (void) newActivity: (id) sender
{
	NSLog(@"newActivity");
	Context *ctx = [Context sharedContext];
	NSMenuItem *mi = (NSMenuItem *) sender;
	
	ctx.currentTask = [mi representedObject];
	
	// if we get don't get the default or empty then it is "adhoc" task  (with no source)
	
	if (ctx.currentTask == nil){
		if (![mi.title isEqualToString:@"No Current Task"] && [mi.title length] > 0) {
			TaskInfo *newTI = [TaskInfo	new];
			newTI.name = mi.title;
			ctx.currentTask = newTI;
		}
	}
	[ctx saveTask];
	
	// we changed jobs so write a new tracking record
	if (ctx.currentState == WPASTATE_THINKING || ctx.currentState == WPASTATE_THINKTIME){
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:ctx.currentState];
	}
	[ctx.growlManager growlThis:[NSString stringWithFormat: @"New Activity: %@",ctx.currentTask.name]];
	[self buildStatusMenu];
}

- (IBAction) clickAddActivity: (id) sender
{
	addActivityWindow = [[AddActivityDialogController alloc] initWithWindowNibName:@"AddActivityDialog"];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(addActClosed:) 
												 name:NSWindowWillCloseNotification 
											   object:addActivityWindow.window];
	[addActivityWindow.window makeKeyAndOrderFront:self];
	[addActivityWindow.window setOrderedIndex:0];
	[NSApp runModalForWindow:addActivityWindow.window];
}

- (void) addActClosed: (NSNotification*) notify
{
	[NSApp stopModal];
	[self enableStatusMenu:YES];
	[self buildStatusMenu];
	[[NSNotificationCenter defaultCenter] removeObserver:self  
													name:NSWindowWillCloseNotification 
												  object:addActivityWindow];
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
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	if (on == NO){
//		[(WPADelegate*)[[NSApplication sharedApplication] delegate] stop];
		startButton.title = @"Start";
		[startButton setAction: @selector(clickStart:)];
		[ctx.growlManager stop];
		newState = WPASTATE_OFF;
		[statusTimer invalidate];
		[center removeObserver:self name:@"com.workplayaway.wpa" object:nil];
	} else {
		startButton.title = @"Stop";
		[startButton setAction: @selector(clickStop:)];
		statusTimer = [NSTimer scheduledTimerWithTimeInterval:totalsManager.interval 
													   target: self 
													 selector:@selector(updateStatus:) 
													 userInfo:nil 
													  repeats:NO];
		ctx.growlManager = [GrowlManager new];
		newState = WPASTATE_FREE;
		// start listening for pause commands
		[center addObserver:self selector:@selector(remoteNotify:) name:@"com.workplayaway.wpa" object:nil];
	}
	ctx.running = on;
//	[self enableUI:ctx.running];
//	[self buildStatusMenu];
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
- (void) showSummaryScreen: (id) sender
{
	[self enableStatusMenu:NO];
	Context *ctx = [Context sharedContext];
	SummaryHUDControl *shc = [[SummaryHUDControl alloc]initWithWindowNibName:@"SummaryHUD"];
	hudWindow = shc.window;
	[hudWindow orderOut:self];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(summaryClosed:) 
												 name:NSWindowWillCloseNotification 
											   object:shc.window];

	ctx.currentState = WPASTATE_SUMMARY;
	[self buildStatusMenu];
	[shc processSummary];
	
}

- (void) summaryClosed:(NSNotification*) notification{
	NSLog(@"summaryClosed");
	[[NSNotificationCenter defaultCenter] removeObserver:self  
												 name:NSWindowWillCloseNotification 
											   object:nil];
	
	// after a summary is displayed then turn off the refresh cycle
	if (refreshManager == nil) {
		refreshManager = [[RefreshManager alloc]initWithHandler:[Context sharedContext].growlManager];
	}
	[[Context sharedContext].growlManager clearQueues];
	[refreshManager startWithRefresh:NO];

	[controls setSelectedSegment: WPASTATE_FREE];
	[self changeState:WPASTATE_FREE];
}

- (void) remoteNotify: (NSNotification*) notification
{	
	NSDictionary *dict = [notification userInfo];
	NSNumber *minStr =  [dict objectForKey:@"time"];
	NSNumber *state =  [dict objectForKey:@"state"];
	switch ([state intValue]) {
		case WPASTATE_THINKTIME:
			[self doThinkTime: [minStr intValue]];
			break;
		case WPASTATE_AWAY:
			[self clickAway:nil];
			break;
		case WPASTATE_THINKING:
			[self clickWork:nil];
			break;
		case WPASTATE_FREE:
			[self clickAway:nil];
			break;
		default:
			break;
	}
}

- (void) doThinkTime: (NSTimeInterval) thinkMin 
{
	Context *ctx = [Context sharedContext];
	ctx.thinkTime = thinkMin  * 60;
	[ctx saveDefaults];
	thinkTimer = [NSTimer scheduledTimerWithTimeInterval:ctx.thinkTime 
												  target:self 
												selector:@selector(timerAlarm:) 
												userInfo:[NSNumber numberWithDouble:ctx.thinkTime] 
												 repeats:NO];
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:WPASTATE_THINKING];
	[ctx busyModules];
	[controls setSelectedSegment: WPASTATE_THINKTIME];
	[self buildStatusMenu];   
}

- (void) changeState: (WPAStateType) newState
{
	Context *ctx = [Context sharedContext];
	//
	// were we just away for a (longish) while?
	if (newState == WPASTATE_FREE)
	{
		if ([self needsSummary]){
			[self showSummaryScreen: self];
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
		[self enableStatusMenu:NO];
		[tdcWindow orderFrontRegardless];
		[NSApp runModalForWindow: tdcWindow];
		[self enableStatusMenu:YES];
		if (ctx.thinkTime){
			thinkTimer = [NSTimer scheduledTimerWithTimeInterval:ctx.thinkTime 
													  target:self 
														selector:@selector(timerAlarm:) 
														userInfo:[NSNumber numberWithDouble:ctx.thinkTime] 
														 repeats:NO];
			
		}
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
	if (newState == WPASTATE_OFF){
		[ctx stopModules];
	}
	ctx.currentState = newState == WPASTATE_THINKTIME ? WPASTATE_THINKING : newState;
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] newRecord:newState];
	[ctx saveDefaults];
	[self buildStatusMenu];
	[self enableUI:(newState != WPASTATE_OFF)];
	if (refreshManager == nil && newState != WPASTATE_OFF){
		refreshManager = [[RefreshManager alloc]initWithHandler:ctx.growlManager];
		[refreshManager startWithRefresh:YES];
	}
	if (newState == WPASTATE_OFF){
		[refreshManager stop];
		refreshManager = nil;
	}
}

- (void) timerAlarm: (NSTimer*) timer 
{
	NSSound *systemSound = [NSSound soundNamed:[Context sharedContext].alertName];
	[systemSound play];
	[self changeState:WPASTATE_FREE];
	[thinkTimer invalidate];
	thinkTimer  = nil;
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
	[ctx.growlManager growlThis:[NSString stringWithFormat: @"New Activity: %@",ctx.currentTask.name]];

}


-(void) statusHandler: (NSNotification*) notification
{
	controls.selectedSegment = WPASTATE_FREE; 
}

- (void) clickRefresh:(id)sender
{
	[[Context sharedContext]refreshTasks];
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

- (void) popStatusMenu
{
	[statusItem popUpStatusItemMenu:statusMenu];
}

- (IBAction) clickPreferences: (id) sender
{
    if (prefsWindow == nil) {
        prefsWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
	[prefsWindow showWindow:self];
}



-(IBAction) clickStatsWindow: (id) sender
{
	if (statsWindow == nil)
		statsWindow = [[StatsWindow alloc] initWithWindowNibName:@"StatsWindow"];
	[statsWindow showWindow:self];
	[[statsWindow window] makeKeyAndOrderFront:self];
	[[statsWindow window] setOrderedIndex:0];
}



OSStatus hotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
						 void *userData)
{
	WPAMainController *self = (WPAMainController*) userData;
	//Do something once the key is pressed
	[self popStatusMenu];
	return noErr;
}

- (void) setupHotKey
{
	//Register the Hotkeys
	EventHotKeyRef gMyHotKeyRef;
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	
	InstallApplicationEventHandler(&hotKeyHandler,1,&eventType,(void*)self,NULL);
	
	gMyHotKeyID.signature='htk1';
	gMyHotKeyID.id=1;
	
	
	RegisterEventHotKey(24, cmdKey+optionKey, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
}

@end
