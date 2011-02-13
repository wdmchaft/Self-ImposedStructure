//
//  WPAMainController.h
//  Nudge
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "AddModWinController.h"
#import "WPADelegate.h"
#import "State.h"
#import "StatsWindow.h"
#import "RefreshManager.h"
#import "GrowlManager.h"
#import "StatusIconView.h"
#import "TotalsManager.h"
#import "PreferencesWindow.h"
#import "AddActivityDialogController.h"

@interface WPAMainController :NSObject <NSComboBoxDelegate,NSWindowDelegate> {
	NSWindow *myWindow;
	NSButton *startButton;
	NSSegmentedControl *controls;
	NSComboBox *taskComboBox;
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
}

@property (retain, nonatomic) IBOutlet NSWindow	*myWindow;
@property (retain, nonatomic) IBOutlet NSButton *startButton;
@property (retain, nonatomic) IBOutlet NSButton *refreshButton;
@property (retain, nonatomic) IBOutlet NSSegmentedControl *controls;
@property (retain, nonatomic) IBOutlet NSComboBox *taskComboBox;
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

- (IBAction) clickStart: (id) sender;
- (IBAction) clickControls: (id) sender;
-(IBAction) changeCombo: (id)sender;
-(IBAction) clickRefresh: (id) sender;
-(IBAction) clickAway: (id) sender;
-(IBAction) clickPlay: (id) sender;
-(IBAction) clickWork: (id) sender;
-(IBAction) clickTimed: (id) sender;
- (void) changeState: (WPAStateType) state;
- (void) tasksChanged: (NSNotification*) notification;

- (void)handleScreenSaverStart:(NSNotification*) notification;
-(void)handleScreenSaverStop:(NSNotification*) notification;
- (void) enableUI: (BOOL) onOff;
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
- (void) fillActivities:(NSMenu*) menu;
- (void) newActivity: (id) sender;
- (void) setupHotKeyIfNecessary;
- (void) setupHotKey;
- (IBAction) showSummaryScreen: (id) sender;

- (void) prefsClosed: (NSNotification*) notify;
- (void) statsClosed: (NSNotification*) notify;
- (void) clickPreferences: (id) sender;
- (void) clickStatsWindow: (id) sender;
- (void) addActClosed: (NSNotification*) notify;

@end
