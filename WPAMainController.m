//
//  WPAMainController.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "WPAMainController.h"
#import "WPADelegate.h"
#include "Context.h"
#include "Columns.h"
#import "TimerDialogController.h"
#import "SummaryHUDControl.h"
#import "AddActivityDialogController.h"
#import "Menu.h"
#import "MinsToSecsTransformer.h"
#import "SecsToMinsTransformer.h"
#import "WriteHandler.h"
#import "GoalHoursToAverageXForm.h"
#import "VacationDialog.h"
#import "SwitchActivityDialog.h"

@implementation WPAMainController
@synthesize  startButton, refreshButton, statusItem, statusMenu, statusTimer, myWindow, menuForTaskList, modalSession;
@synthesize hudWindow, refreshManager, thinkTimer, siView, totalsManager, prefsWindow, statsWindow, addActivityWindow;
@synthesize switchActivityDialog;

+ (void)initialize{
	GoalHoursToAverageXForm *ghtav;
    ghtav = [GoalHoursToAverageXForm new];
	// register it with the name that we refer to it with
	[NSValueTransformer setValueTransformer:ghtav
									forName:@"GoalHoursToAverageXForm"];	
	
    MinsToSecsTransformer *mToSTransformer;
	
	// create an autoreleased instance of our value transformer
	mToSTransformer = [[[MinsToSecsTransformer alloc] init]
					   autorelease];
	
	// register it with the name that we refer to it with
	[NSValueTransformer setValueTransformer:mToSTransformer
									forName:@"MinsToSecsTransformer"];								

	SecsToMinsTransformer *sToMTransformer;
	 
	// create an autoreleased instance of our value transformer
	sToMTransformer = [[[SecsToMinsTransformer alloc] init]
						autorelease];
	 
	// register it with the name that we refer to it with
	[NSValueTransformer setValueTransformer:sToMTransformer
									 forName:@"SecsToMinsTransformer"];									
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"YES",							@"autoBackToWork",
								 @"YES",							@"showSummary",
								 @"NO",								@"useHotKey",
								 @"NO",								@"startOnLoad",
								 @"NO",								@"ignoreScreenSaver",
								 [NSNumber numberWithDouble:600],	@"nagDelayTime",
								 [NSNumber numberWithDouble:3600],	@"timeAwayThreshold",
								 [NSNumber numberWithDouble:600],	@"backToWorkThreshold",
								 [NSNumber numberWithDouble:20.0 * 60 * 60], @"weeklyGoal",
								 [NSNumber numberWithDouble:4.0 * 60 * 60],	@"dailyGoal",
								 [NSNumber numberWithDouble:1800],	@"thinkTime",
								 [NSNumber numberWithDouble:30],	@"growlFrequency",
								 [NSNumber numberWithInt:WPASTATE_OFF], @"currentState",
								 [NSNumber numberWithInt:WPASTATE_FREE], @"previousState",
								 [NSDate distantPast],				@"lastStateChange",
								 @"Beep",							@"alertName",
                                 [NSNumber numberWithInt: 30],         @"wakeDelayInteval",
								 nil];
	
    [defaults registerDefaults:appDefaults];


}

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
	[center addObserver: self selector:@selector(endTimed:)
				   name:@"com.zer0gravitas.alarm" object:nil];
	[center addObserver: self selector:@selector(tasksChanged:)
				   name:@"com.zer0gravitas.tasks" object:nil];
    
    NSNotificationCenter *wsCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	[wsCenter addObserver:self
                 selector:@selector(handleWillSleep:)
                     name:NSWorkspaceWillSleepNotification
                   object:nil];
     [wsCenter addObserver:self
                  selector:@selector(handleWakeFromSleep:)
                      name:NSWorkspaceDidWakeNotification
                    object:nil];
	// start listening for commands
	NSDistributedNotificationCenter *dCenter = [NSDistributedNotificationCenter defaultCenter];
	// for the screensaver
	[dCenter addObserver:self selector:@selector(handleScreenSaverStart:) name:@"com.apple.screensaver.didlaunch" object:nil];
	[dCenter addObserver:self selector:@selector(handleScreenSaverStop:) name:@"com.apple.screensaver.didstop" object:nil];
	[self enableUI: ctx.running];
		
	totalsManager = [TotalsManager new];
	[totalsManager setRollDelegate:self];
	if (ctx.currentState == WPASTATE_VACATION && [totalsManager isVacationToday] == NO){
		[ctx setCurrentState: WPASTATE_FREE];
	}
    BOOL pastGoal = totalsManager.workToday >= [totalsManager calcGoal];
    //NSLog(@"starting with goal acheived? [%@]", pastGoal ? @"YES" : @"NO");
    if (ctx.currentState != WPASTATE_VACATION && pastGoal){
        [ctx setCurrentState:WPASTATE_DONE]; 
    }
    ctx.totalsManager = totalsManager;
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	statusItem.menu = statusMenu;
	//[statusItem setTitle:@"X"];
	[self buildStatusMenu];
	[statusItem setHighlightMode:YES];
	[statusMenu  setAutoenablesItems:NO];
	statusTimer = [NSTimer scheduledTimerWithTimeInterval:totalsManager.interval
												   target: self 
												 selector:@selector(updateStatus:) 
												 userInfo:nil 
												  repeats:NO];
	[self setupHotKeyIfNecessary];
}

-(void) updateStatus: (NSTimer*) timer
{
	Context *ctx = [Context sharedContext];
	[self buildStatusMenu];
    [statusTimer invalidate];
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

- (void) askForVacation
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];	
	VacationDialog *vacaDialog = [[VacationDialog alloc] initWithWindowNibName:@"VacationDialog"];
	[NSApp runModalForWindow: [vacaDialog window]];
	if ([vacaDialog onVacation] == YES){
		[self clickVacation: self];
	}
}

- (void) unVacation
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	NSAlert *alert = [NSAlert alertWithMessageText:@"Tsk. Tsk." 
									 defaultButton:@"I guess not." alternateButton:@"Yes please." 
									   otherButton:nil 
						 informativeTextWithFormat:@"Your vacation time is important.  You sure you wanna do this?"];	
	NSUInteger ans = [alert runModal];
	if (ans != NSAlertDefaultReturn){
		[self clickPlay:self];
	}
}
-(void) buildStatusMenu
{
	Context *ctx = [Context sharedContext];
	WPAStateType currState = ctx.currentState;
	NSRect rect = {{0,0},{22.0,22.0}};
	if (siView == nil) {
		siView = [[StatusIconView alloc]initWithFrame:rect];
		siView.statusItem = statusItem;
		siView.statusMenu = statusMenu;
	}
	siView.timer = thinkTimer;
    double goal = [totalsManager calcGoal];
	siView.goal = goal;
	siView.work = totalsManager.workToday;
	siView.free = totalsManager.freeToday;
	siView.state = ctx.currentState;
	[statusItem setView:siView];
	
	[[statusMenu itemWithTag:MENU_WORK] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_AWAY] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_FREE] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_TIMED] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_VACA] setState:NSOffState];
	[[statusMenu itemWithTag:MENU_STOPSTART] setTitle:(currState == WPASTATE_OFF) ? @"Start" 
																					: @"Stop"];
	[[statusMenu itemWithTag:MENU_STOPSTART] setAction:(currState == WPASTATE_OFF) ? @selector(clickStart:) 
																					: @selector(clickStop:)];

	if ([ctx isWorkingState]){
		[[statusMenu itemWithTag:MENU_WORK] setEnabled:YES];
		[[statusMenu itemWithTag:MENU_AWAY] setEnabled:YES];
		[[statusMenu itemWithTag:MENU_FREE] setEnabled:YES];
		[[statusMenu itemWithTag:MENU_TIMED] setEnabled:YES];
		[[statusMenu itemWithTag:MENU_ACTIVITIES] setHidden:NO];
		if (currState == WPASTATE_FREE) {
			[[statusMenu itemWithTag:MENU_FREE] setState:NSOnState];
		}
		if (currState == WPASTATE_AWAY) {
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
		else if (currState == WPASTATE_THINKING) {
			[[statusMenu itemWithTag:MENU_WORK] setState:NSOnState];
		}
		NSMenuItem *aMenuItem = [statusMenu itemWithTag:MENU_ACTIVITIES];
		[self fillActivities:aMenuItem.submenu];
		[[statusMenu itemWithTag:MENU_STOPSTART] setTitle:@"Stop"];
		[[statusMenu itemWithTag:MENU_STOPSTART] setAction:@selector(clickStop:)];
	}
	else {
		[[statusMenu itemWithTag:MENU_WORK] setEnabled:NO];
		[[statusMenu itemWithTag:MENU_AWAY] setEnabled:NO];
		[[statusMenu itemWithTag:MENU_FREE] setEnabled:NO];
		[[statusMenu itemWithTag:MENU_TIMED] setEnabled:NO];
		[[statusMenu itemWithTag:MENU_ACTIVITIES] setHidden:YES];
	} 
	[[statusMenu itemWithTag:MENU_SUMMARY] setEnabled: currState != WPASTATE_SUMMARY];
	NSString *vacaTitle = (currState == WPASTATE_VACATION ? @"Just Kidding..." : @"Vacation...");
	SEL vacaAction = (currState == WPASTATE_VACATION) ? @selector(unVacation) : @selector(askForVacation);
	[[statusMenu itemWithTag:MENU_VACA] setTitle: vacaTitle];
	[[statusMenu itemWithTag:MENU_VACA] setAction:vacaAction];
}

- (NSArray*) getTasklists {
    NSDictionary *instancesMap = [Context sharedContext].instancesMap;
	NSMutableArray *insts = [NSMutableArray new];
	NSString *name = nil;
	for (name in instancesMap){
		id thing = [instancesMap objectForKey: name];
		id<TaskList> list  = (id<TaskList>) thing;
		id<Instance> inst  = (id<Instance>) thing;
		if (inst.enabled && [thing conformsToProtocol:@protocol(TaskList)]){
            [insts addObject:list];
        }
	}
	return insts;
}

- (BOOL) matchTask:(NSDictionary*) info1 toTask:(NSDictionary*) info2
{
	NSString *name1 = [info1 objectForKey:@"name"];
	NSString *name2 = [info2 objectForKey:@"name"];
	if (![name1 isEqualToString:name2]){
		return NO;
	}
	NSString *src1 = [info1 objectForKey:@"source"];
	NSString *src2 = [info2 objectForKey:@"source"];	
	if (src1 == nil && src2 == nil){
	} else if ([src1 isEqualToString:src2]) {
		
	} else {
		return NO;
	}
	return YES;
}

- (void) fillListActivities: (id<TaskList>) list
{
	Context *ctx = [Context sharedContext];	
	NSMenuItem *aMenuItem = [statusMenu itemWithTag:MENU_ACTIVITIES];
	NSMenu *fillMenu = aMenuItem.submenu;
	for(NSDictionary *info in [list getTasks]){
        NSString *description = [info objectForKey:@"name"];
		NSMenuItem *mi = [[NSMenuItem alloc]initWithTitle:description 
												   action:@selector(newActivity:)
											keyEquivalent:@""];
		[mi setTarget:self];
        NSDictionary *attrs = [NSDictionary dictionaryWithObject:[NSFont messageFontOfSize:12.0] forKey:NSFontAttributeName];
        NSString *desc = [NSString stringWithFormat:@"   %@", description];
        NSAttributedString *attrTitle = [[NSAttributedString alloc]initWithString:desc attributes:attrs];
        [mi setAttributedTitle:attrTitle];
        NSMenuItem *myItem = [menuForTaskList objectForKey:list.name];
        int idx = [fillMenu indexOfItem:myItem];
		mi.state = NSOffState;
		[mi setEnabled:YES];
		[mi setRepresentedObject:info];
		if (ctx.currentTask && [self matchTask:ctx.currentTask toTask:info]){
			mi.state = NSOnState;
        }
		[fillMenu insertItem:mi atIndex:idx+1]; 
	}
}

- (void) fillActivities: (NSMenu*) menu
{
	[menu setAutoenablesItems:NO];
	Context *ctx = [Context sharedContext];
	if (ctx.tasksList == nil || [ctx.tasksList count] == 0){
		ctx.tasksList = [ctx getTasks];
	}
	// clear anything out first
	while ([[menu itemArray] count] > 3) {
		NSMenuItem *mi = [menu itemAtIndex:3];
		[menu removeItem:mi];
	}
    NSArray *lists = [self getTasklists];
	menuForTaskList= [NSMutableDictionary dictionaryWithCapacity:[lists count]];
    for (id<Instance> tasklist in  lists){
        
        NSMenuItem *mi = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@:",tasklist.name]
												   action:@selector(newActivity:)
											keyEquivalent:@""];
        [mi setRepresentedObject:tasklist];
        [menu addItem:mi];
        [menuForTaskList setObject:mi forKey:tasklist.name];
  //      NSMenuItem *sep = [NSMenuItem separatorItem];
   //     [menu addItem:sep];
    }
	for(id<TaskList> tasklist in lists){
        [self fillListActivities:tasklist];
	}
}

- (void) tasksChanged:(NSNotification *)notification
{
	id<TaskList> list = [notification object];
	[self fillListActivities:list];
}

- (void) newActivity: (id) sender
{
	//NSLog(@"newActivity");
	Context *ctx = [Context sharedContext];
	NSMenuItem *mi = (NSMenuItem *) sender;
	
	ctx.currentTask = [mi representedObject];
	
	// if we get don't get the default or empty then it is "adhoc" task  (with no source)
	
	if (ctx.currentTask == nil){
		if (![mi.title isEqualToString:@"No Current Task"] && [mi.title length] > 0) {
			ctx.currentTask = [[NSDictionary dictionaryWithObject:mi.title forKey:@"name"] copy];
		}
	}
	[ctx saveTask];
	
	NSDictionary *task = ctx.currentTask;
	//[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"New Activity: %@",[task objectForKey:@"name"]]];
	WPAAlert *newTaskMsg = [WPAAlert new];
	NSString *src = [task objectForKey:@"source"];
	newTaskMsg.title = [NSString stringWithFormat:@"New Activity from [%@]", src];
	newTaskMsg.message = [task objectForKey:@"name"];
	newTaskMsg.clickable = YES;
	newTaskMsg.moduleName = src;
	newTaskMsg.params = task;
	newTaskMsg.isWork = [(NSNumber*)[task objectForKey:@"work"] boolValue];
	newTaskMsg.urgent = YES;
	
	[[ctx growlManager] growlAlert:newTaskMsg];
	[self buildStatusMenu];
}

- (void)loadModalWindow: (NSWindowController*) win class: (Class) clazz nibName: (NSString*) name callback: (SEL) cb
{
	win = [[clazz alloc] initWithWindowNibName:name];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:cb
												 name:NSWindowWillCloseNotification 
											   object:[win window]];
	[win.window makeKeyAndOrderFront:self];
	[win.window setOrderedIndex:0];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[win showWindow:self];
	modalSession = [NSApp beginModalSessionForWindow:win.window];
	[NSApp runModalSession:modalSession];
}

- (IBAction) clickSwitchActivity: (id) sender
{
	[self loadModalWindow: switchActivityDialog 
					class:[SwitchActivityDialog class] 
				  nibName: @"SwitchActivityDialog"
				 callback: @selector(switchActClosed:)];
}

- (IBAction) clickAddActivity: (id) sender
{
	[self loadModalWindow: addActivityWindow 
					class: [AddActivityDialogController class]
				  nibName: @"AddActivityDialog"
				 callback: @selector(addActClosed:)];
}

- (void) addActClosed: (NSNotification*) notify
{
	[NSApp endModalSession:modalSession];
	[[Context sharedContext]refreshTasks];
	[self enableStatusMenu:YES];
	[self buildStatusMenu];
	[[NSNotificationCenter defaultCenter] removeObserver:self  
													name:NSWindowWillCloseNotification 
												  object:addActivityWindow];
}

- (void) switchActClosed: (NSNotification*) notify
{
	[NSApp endModalSession:modalSession];
	[[Context sharedContext]refreshTasks];
	[self enableStatusMenu:YES];
	[self buildStatusMenu];
	[[NSNotificationCenter defaultCenter] removeObserver:self  
													name:NSWindowWillCloseNotification 
												  object:switchActivityDialog];
}
- (void) enableUI: (BOOL) onOff
{
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
		[[ctx growlManager] stop];
		newState = WPASTATE_OFF;
		[statusTimer invalidate];
		[center removeObserver:self name:@"com.zer0gravitas.selfstruct" object:nil];
	} else {
		startButton.title = @"Stop";
		[startButton setAction: @selector(clickStop:)];
		statusTimer = [NSTimer scheduledTimerWithTimeInterval:0 
													   target: self 
													 selector:@selector(updateStatus:) 
													 userInfo:nil 
													  repeats:NO];
		//ctx.growlManager = [GrowlManager new];
		newState = WPASTATE_FREE;
		// start listening for pause commands
		[center addObserver:self selector:@selector(remoteNotify:) name:@"com.zer0gravitas.selfstruct.changestate" object:nil];
	}
	ctx.running = on;
//	[self enableUI:ctx.running];
//	[self buildStatusMenu];
	[self changeState:newState];
}

- (IBAction) clickTimed: (id) sender
{
	[self changeState: WPASTATE_THINKTIME];
}

- (IBAction) clickWork: (id) sender
{
	[self changeState: WPASTATE_THINKING];
}

- (IBAction) clickPlay: (id) sender
{
	[self changeState: WPASTATE_FREE];
}

- (IBAction) clickAway: (id) sender
{
	[self changeState: WPASTATE_AWAY];
}

- (IBAction) clickVacation: (id) sender
{
	[self changeState: WPASTATE_VACATION];
    [[[Context sharedContext] growlManager] growlThis:@"Enjoy your day off!" isSticky:YES withTitle:@"Bon Voyage!"];
}

// decide if we need to display a summary screen - this should be shown if 
// 1 the preferences say show it at all
// 2 the user is back from power off or sleep
// 3 and he was away for a time longer than the preferred threshold
//
- (BOOL) needsSummary
{
	Context *ctx = [Context sharedContext];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL showSummary = [ud boolForKey:@"showSummary"];
	NSDate *now = [[NSDate alloc]init];
	if (showSummary == YES){
		if (ctx.currentState!= WPASTATE_FREE && ctx.currentState != WPASTATE_SUMMARY) {
			NSDate *lastChange = [[NSUserDefaults standardUserDefaults]objectForKey:@"lastStateChange"];
			NSTimeInterval timeAway = [now timeIntervalSinceDate:lastChange];
			NSTimeInterval taInt =[ud doubleForKey:@"timeAwayThreshold"];
			if (timeAway > taInt){
				return YES;
			}
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
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL autoBackToWork = [ud boolForKey:@"autoBackToWork"];
	if (autoBackToWork && (ctx.currentState == WPASTATE_THINKTIME || ctx.previousState == WPASTATE_THINKING)){
		if (ctx.previousState == WPASTATE_AWAY || ctx.currentState == WPASTATE_OFF) {
			NSDate *lastChange = [ud objectForKey:@"lastStateChange"];
			NSTimeInterval timeAway = [[NSDate date] timeIntervalSinceDate:lastChange];
			NSTimeInterval brbInt= [ud doubleForKey:@"backToWorkThreshold"];
			if (timeAway < brbInt)
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
	Context *ctx = [Context sharedContext];
	[ctx setCurrentState: WPASTATE_SUMMARY];
	[[[Context sharedContext] growlManager] clearQueues];
	[self enableStatusMenu:NO];
	SummaryHUDControl *shc = [[SummaryHUDControl alloc]initWithWindowNibName:@"SummaryHUD"];
	hudWindow = shc.window;
	[shc showWindow:self];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(summaryClosed:) 
												 name:NSWindowWillCloseNotification 
											   object:shc.window];

	[self buildStatusMenu];	
}

- (void) summaryClosed:(NSNotification*) notification{
	//NSLog(@"summaryClosed");

    NSWindow *win = [notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self  
												 name:NSWindowWillCloseNotification 
											   object:nil];
	//NSLog(@"save hud string: %@", [win stringWithSavedFrame]);
	NSString *pos = [win stringWithSavedFrame];
	[[NSUserDefaults standardUserDefaults] setObject:pos forKey: @"posHUD"];
	
	// after a summary is displayed then turn off the refresh cycle
	if (refreshManager == nil) {
		refreshManager = [[RefreshManager alloc]initWithHandler:[[Context sharedContext] growlManager]];
	}
	[refreshManager startWithRefresh:NO];

	if ([[Context sharedContext] previousState] == WPASTATE_VACATION){
		[self changeState:WPASTATE_VACATION];
	}
    else if ([[Context sharedContext] previousState] == WPASTATE_DONE){
		[self changeState:WPASTATE_DONE];
	}
	else {
		[self changeState:WPASTATE_FREE];
	}
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
			[self clickPlay:nil];
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
	[ctx busyModules];
	[self buildStatusMenu];   
}

- (void) changeState: (WPAStateType) newState
{
    
	Context *ctx = [Context sharedContext];
    BOOL pastGoal = totalsManager.workToday >= [totalsManager calcGoal];

    if (ctx.currentState == WPASTATE_DONE && pastGoal){
        return;
    }
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
			[ctx startNagDelay];
		}
	}  
	if (newState != WPASTATE_FREE) {
		[ctx endNagDelay:nil];
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
    if (newState == WPASTATE_VACATION){
		[ctx vacationModules];
	}
	if (newState == WPASTATE_OFF){
		[ctx stopModules];
	}
    if (newState  == WPASTATE_THINKTIME){
        newState = WPASTATE_THINKING;
    }
	[ctx setCurrentState: newState];
    
	//[WriteHandler sendNewRecord:newState];
	[ctx saveDefaults];
	[self buildStatusMenu];
	[self enableUI:(newState != WPASTATE_OFF)];
	if (refreshManager == nil && newState != WPASTATE_OFF){
		refreshManager = [[RefreshManager alloc]initWithHandler:[ctx growlManager]];
		[refreshManager startWithRefresh:YES];
	}
	if (newState == WPASTATE_OFF){
		[refreshManager stop];
		refreshManager = nil;
	}
}

- (void) timerAlarm: (NSTimer*) timer 
{
	NSString *alertName = [[NSUserDefaults standardUserDefaults] objectForKey:@"alertName"];
	NSSound *systemSound = [NSSound soundNamed:alertName];
	[systemSound play];
	[self changeState:WPASTATE_FREE];
	[thinkTimer invalidate];
	thinkTimer  = nil;
}
					  


-(void) endTimed: (NSNotification*) notification
{
	[self changeState:WPASTATE_FREE];
}

- (void) clickRefresh:(id)sender
{
	[[Context sharedContext]refreshTasks];
}

-(void)handleScreenSaverStart:(NSNotification*) notification
{	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if (![ud boolForKey:@"ignoreScreenSaver"]){
		[self changeState:WPASTATE_AWAY]; 
	}
}

-(void)handleScreenSaverStop:(NSNotification*) notification
{	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if (![ud boolForKey:@"ignoreScreenSaver"]){
		[self changeState:WPASTATE_FREE]; 
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
	[[prefsWindow window] makeKeyAndOrderFront:self];
	[[statsWindow window] setOrderedIndex:0];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

-(IBAction) clickStatsWindow: (id) sender
{
	if (statsWindow == nil)
		statsWindow = [[StatsWindow alloc] initWithWindowNibName:@"StatsWindow"];
	[statsWindow showWindow:self];
	[[statsWindow window] makeKeyAndOrderFront:self];
	[[statsWindow window] setOrderedIndex:0];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}



OSStatus hotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
						 void *userData)
{
	WPAMainController *self = (WPAMainController*) userData;
	//Do something once the key is pressed
	[self popStatusMenu];
	return noErr;
}

- (void) setupHotKeyIfNecessary
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useHotKey"])
		[self setupHotKey];
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

- (void) gotRollover
{
	Context *ctx = [Context sharedContext];
	if (ctx.currentState == WPASTATE_VACATION || ctx.currentState == WPASTATE_DONE) {
		[ctx setCurrentState:WPASTATE_FREE];
        [self buildStatusMenu];
    }
}

- (void) gotDone
{
	Context *ctx = [Context sharedContext];
    [ctx setCurrentState:WPASTATE_DONE];
    [self buildStatusMenu];
}

- (void) handleWakeFromSleep: (NSNotification*) msg
{   
    // wait a minute to let the dust settle then start up
    [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] doubleForKey:@"wakeDelayInterval"]
                                     target: self 
                                   selector:@selector(clickPlay:) 
                                   userInfo:self 
                                    repeats:NO];
}

- (void) handleWillSleep: (NSNotification*) msg
{
    [self changeState:WPASTATE_OFF];
}

@end
