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
	NSButton *toggleButton;
	NSComboBox *taskComboBox;
	NSButton *refreshButton;
	StatsWindow *statsWindow;
}

@property (retain, nonatomic) IBOutlet NSButton *startButton;

@property (retain, nonatomic) IBOutlet NSButton *refreshButton;
@property (retain, nonatomic) IBOutlet NSSegmentedControl *controls;
@property (retain, nonatomic) IBOutlet NSComboBox *taskComboBox;

- (IBAction) clickStart: (id) sender;
- (IBAction) clickControls: (id) sender;
-(IBAction) changeCombo: (id)sender;
-(IBAction) clickRefresh: (id) sender;
-(IBAction) clickAway: (id) sender;
-(IBAction) clickPlay: (id) sender;
-(IBAction) clickWork: (id) sender;
-(IBAction) clickTimed: (id) sender;
- (void) changeState: (int) state;

-(void)handleScreenSaverStart:(NSNotification*) notification;
-(void)handleScreenSaverStop:(NSNotification*) notification;
@end
