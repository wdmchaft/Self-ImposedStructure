//
//  WPAMainController.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "AddModWinController.h"
#import "WPADelegate.h"
#import "State.h"
#import "StatsWindow.h"
#import "RefreshManager.h"
#import "StatusIconView.h"
#import "TotalsManager.h"
#import "PreferencesWindow.h"
#import "AddActivityDialogController.h"
#import "RolloverDelegate.h"
#import "WPAMDelegate.h"
#import "TaskList.h"
#import "SwitchActivityDialog.h"

@interface WPAMainController :NSObject <NSWindowDelegate, RolloverDelegate, WPAMDelegate> {
	NSWindow *myWindow;
	NSButton *startButton;
	NSButton *refreshButton;
	StatsWindow *statsWindow;
	PreferencesWindow	*prefsWindow;
	NSStatusItem *statusItem;
	NSMenu *statusMenu;
	NSTimer *statusTimer;
	NSWindow *hudWindow;
	RefreshManager *refreshManager;
	NSTimer *thinkTimer;
	StatusIconView *siView;
	NSTimeInterval dailyWorkTotal;
	NSTimeInterval weeklyWorkTotal;
	TotalsManager *totalsManager;
	AddActivityDialogController *addActivityWindow;
	SwitchActivityDialog *switchActivityDialog;
	NSMutableDictionary *menuForTaskList;
	NSModalSession modalSession;
	NSString *stateQueue;
	NSString *completeQueue;
}

@property (retain, nonatomic) IBOutlet NSWindow	*myWindow;
@property (retain, nonatomic) IBOutlet NSButton *startButton;
@property (retain, nonatomic) IBOutlet NSButton *refreshButton;
@property (retain, nonatomic) IBOutlet NSStatusItem *statusItem;
@property (retain, nonatomic) IBOutlet NSMenu *statusMenu;
@property (retain, nonatomic)  NSTimer *statusTimer;
@property (retain, nonatomic)  NSWindow *hudWindow;
@property (retain, nonatomic)  RefreshManager *refreshManager;
@property (retain, nonatomic)  NSTimer *thinkTimer;
@property (retain, nonatomic)  StatusIconView *siView;
@property (retain, nonatomic)  TotalsManager *totalsManager;
@property (retain, nonatomic) PreferencesWindow *prefsWindow;
@property (retain, nonatomic) StatsWindow *statsWindow;
@property (retain, nonatomic) AddActivityDialogController *addActivityWindow;
@property (retain, nonatomic) SwitchActivityDialog *switchActivityDialog;
@property (retain, nonatomic) NSMutableDictionary *menuForTaskList;
@property (retain, nonatomic) NSString *stateQueue ;
@property (retain, nonatomic) NSString *completeQueue ;
@property (nonatomic) NSModalSession modalSession;

- (IBAction) clickManageProjects: (id) sender;
- (IBAction) clickStart: (id) sender;
- (IBAction) clickRefresh: (id) sender;
- (IBAction) clickAway: (id) sender;
- (IBAction) clickPlay: (id) sender;
- (IBAction) clickWork: (id) sender;
- (IBAction) clickTimed: (id) sender;
- (IBAction) clickVacation: (id) sender;
- (void) changeState: (WPAStateType) state;
- (void) tasksChanged: (NSNotification*) notification;

- (void) handleWakeFromSleep:(NSNotification*) notification;
- (void) handleWillSleep:(NSNotification*) notification;
- (void) handleScreenSaverStart:(NSNotification*) notification;
- (void) handleScreenSaverStop:(NSNotification*) notification;

- (void) enableUI: (BOOL) onOff;
- (void) buildStatusIcon;
- (void) buildStatusMenu;
- (void) enableStatusMenu: (BOOL) onOff;
- (void) updateStatus: (NSTimer*) timer;
- (BOOL) shouldGoBackToWork;
- (BOOL) needsSummary;
- (void) running: (BOOL) onOff;
- (void) summaryClosed:(NSNotification*) notification;
- (void) remoteNotify: (NSNotification*) notification;
- (void) doThinkTime: (NSTimeInterval) thinkMin ;
- (void) popStatusMenu;
- (IBAction) clickAddActivity: (id) sender;
- (IBAction) clickSwitchActivity: (id) sender;
- (void) fillActivities:(NSMenu*) menu;
- (void) newActivity: (id) sender;
- (void) setupHotKeyIfNecessary;
- (IBAction) showSummaryScreen: (id) sender;

- (void) clickPreferences: (id) sender;
- (void) clickStatsWindow: (id) sender;
- (void) addActClosed: (NSNotification*) notify;
- (void) switchActClosed: (NSNotification*) notify;

- (NSString *) completeQueue;
- (NSString *) stateQueue;

@end
