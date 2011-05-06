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
#import "HUDBusy.h"

@interface SummaryHUDControl :  NSWindowController <SummaryHUDCallback, NSWindowDelegate> {
	NSMutableDictionary *svcs;
	NSMutableDictionary *controls;
	NSMutableDictionary *datas;
	NSMutableDictionary *busys;
	
	NSView *view;

	WPAMainController *mainControl;
 
    NSMutableData *frameData;
    CGFloat lineHeight;
	NSUInteger sizedCount;
	NSString *framePos;
	BOOL viewChanged;
	NSTimer *buildTimer;
	NSRect saveRect;
	BOOL oneLastTime;
}
@property (nonatomic, retain) NSMutableData *frameData;
@property (nonatomic, retain)  NSMutableDictionary *svcs;
@property (nonatomic, retain)  NSMutableDictionary *controls;
@property (nonatomic, retain)  NSMutableDictionary *datas;
@property (nonatomic, retain)  NSMutableDictionary *busys;
@property (nonatomic, retain) IBOutlet NSView *view;

@property (nonatomic, retain) WPAMainController *mainControl;
@property (nonatomic, retain) NSString *framePos; // hack since auto frame save is buggy for mysterious reasons
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) NSUInteger sizedCount;
@property (nonatomic) BOOL viewChanged;
@property (nonatomic, retain) NSTimer *buildTimer;
@property (nonatomic) NSRect saveRect;
@property (nonatomic) BOOL oneLastTime;

- (SummaryViewController*) getViewForInstance: (id<Reporter>) inst width: (CGFloat) vWidth rows: (int) nRows;

- (void) buildDisplay;

- (CGFloat) calcHeight;
@end
