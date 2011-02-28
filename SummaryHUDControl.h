//
//  SummaryHudControl.h
//  WorkPlayAway
//
//  Created by Charles on 1/18/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlertHandler.h"
#import "SummaryEventData.h"
#import "SummaryTaskData.h"
#import "SummaryMailData.h"
#import "SummaryDeadlineData.h"
#import "WPAMainController.h"
#import "Reporter.h"
#import "SummaryViewController.h"

@interface SummaryHUDControl : NSWindowController {
	NSArray *modules;
	NSArray *heights;
	NSArray *views;
	NSView *view;
	NSTextField *label1;
	NSTextField *label2;
	NSTextField *label3;
	NSTextField *label4;
	NSTextField *label5;
	NSTextField *label6;
	WPAMainController *mainControl;
}


@property (nonatomic, retain)  NSArray *modules;
@property (nonatomic, retain)  NSArray *heights;
@property (nonatomic, retain)  NSArray *views;
@property (nonatomic, retain) IBOutlet NSView *view;

@property (nonatomic, retain) WPAMainController *mainControl;
@property (nonatomic, retain) IBOutlet 	NSTextField *label1;
@property (nonatomic, retain) IBOutlet 	NSTextField *label2;
@property (nonatomic, retain) IBOutlet 	NSTextField *label3;
@property (nonatomic, retain) IBOutlet 	NSTextField *label4;
@property (nonatomic, retain) IBOutlet 	NSTextField *label5;
@property (nonatomic, retain) IBOutlet 	NSTextField *label6;

- (void) buildDisplay;
- (SummaryViewController*) getViewForInstance: (<Reporter>) inst view: (NSView*) box;


@end
