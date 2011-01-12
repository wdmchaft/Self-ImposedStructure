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

@interface WPAMainController :NSObject <NSComboBoxDelegate> {

	NSButton *startButton;
	NSSegmentedControl *controls;
	NSComboBox *taskComboBox;
	NSButton *refreshButton;
	StatsWindow *statsWindow;
	NSStatusItem *statusItem;
	NSMenu *statusMenu;
	NSTimer *statusTimer;
}

@property (retain, nonatomic) IBOutlet NSButton *startButton;

@property (retain, nonatomic) IBOutlet NSButton *refreshButton;
@property (retain, nonatomic) IBOutlet NSSegmentedControl *controls;
@property (retain, nonatomic) IBOutlet NSComboBox *taskComboBox;
@property (retain, nonatomic) IBOutlet NSStatusItem *statusItem;
@property (retain, nonatomic) IBOutlet NSMenu *statusMenu;
@property (retain, nonatomic) IBOutlet NSTimer *statusTimer;

- (IBAction) clickStart: (id) sender;
- (IBAction) clickControls: (id) sender;
-(IBAction) changeCombo: (id)sender;
-(IBAction) clickRefresh: (id) sender;
-(IBAction) clickAway: (id) sender;
-(IBAction) clickPlay: (id) sender;
-(IBAction) clickWork: (id) sender;
-(IBAction) clickTimed: (id) sender;
- (void) changeState: (int) state;
- (void) tasksChanged: (NSNotification*) notification;

-(void)handleScreenSaverStart:(NSNotification*) notification;
-(void)handleScreenSaverStop:(NSNotification*) notification;
- (void) enableUI: (BOOL) onOff;
- (void) initStatusMenu;
- (void) updateStatus: (NSTimer*) timer;

@end
