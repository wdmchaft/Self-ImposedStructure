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
#import "GrowlDelegate.h"

@interface WPAMainController :NSObject <NSComboBoxDelegate,NSWindowDelegate> {
	NSWindow *myWindow;
	NSButton *startButton;
	NSSegmentedControl *controls;
	NSComboBox *taskComboBox;
	NSButton *refreshButton;
	StatsWindow *statsWindow;
	NSStatusItem *statusItem;
	NSMenu *statusMenu;
	NSTimer *statusTimer;
	NSWindow *hudWindow;
	RefreshManager *refreshManager;
	NSTimer *thinkTimer;
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

-(void)handleScreenSaverStart:(NSNotification*) notification;
-(void)handleScreenSaverStop:(NSNotification*) notification;
- (void) enableUI: (BOOL) onOff;
- (void) initStatusMenu;
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
@end
