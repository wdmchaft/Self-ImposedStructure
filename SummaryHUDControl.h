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
	
	WPAMainController *mainControl;
}


@property (nonatomic, retain)  NSArray *modules;
@property (nonatomic, retain)  NSArray *heights;
@property (nonatomic, retain)  NSArray *views;
@property (nonatomic, retain) IBOutlet NSView *view;

@property (nonatomic, retain) WPAMainController *mainControl;

- (void) buildDisplay;
- (SummaryViewController*) getViewForInstance: (<Reporter>) inst view: (NSView*) box;


@end
