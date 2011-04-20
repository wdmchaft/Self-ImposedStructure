//
//  SummaryHudControl.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/18/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
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
#import "SummaryHUDCallback.h"

@interface SummaryHUDControl :  NSWindowController <SummaryHUDCallback> {
	NSArray *views;
	NSArray *controls;
	NSArray *boxes;
	NSArray *progs;
	NSView *view;

	WPAMainController *mainControl;
 
    NSArray *hudList;
    CGFloat lineHeight;
}
@property (nonatomic,retain) NSArray *hudList;
@property (nonatomic, retain)  NSArray *views;
@property (nonatomic, retain)  NSArray *controls;
@property (nonatomic, retain)  NSArray *boxes;
@property (nonatomic, retain)  NSArray *progs;
@property (nonatomic, retain) IBOutlet NSView *view;

@property (nonatomic, retain) WPAMainController *mainControl;
@property (nonatomic) CGFloat lineHeight;


- (SummaryViewController*) getViewForInstance: (id<Reporter>) inst width: (CGFloat) vWidth rows: (int) nRows;

- (void) buildDisplay;


@end
