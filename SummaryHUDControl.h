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
#import "TotalsManager.h"

@interface TaskView : NSView {
	NSFont *font;
	NSString *titleStr;
	NSString *timeStr;
	NSRect saveFrame;
	CGFloat ratio;
}
@property (nonatomic, retain) NSFont *font;
@property (nonatomic, retain) NSString *titleStr;
@property (nonatomic, retain) NSString *timeStr;
@property (nonatomic, assign) NSRect saveFrame;
@property (nonatomic, assign) CGFloat ratio;
@end

@interface SummaryHUDControl :  NSWindowController <SummaryHUDCallback, NSWindowDelegate> {
	NSMutableDictionary *svcs;
	NSMutableDictionary *controls;
	NSMutableDictionary *datas;
	NSMutableDictionary *busys;
	NSMutableDictionary *titles;
	
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
	TaskView *currentTaskView;
	NSTextView *goalText;
	TotalsManager *totalsManager;
	BOOL useCache;
}
@property (nonatomic, retain) NSMutableData *frameData;
@property (nonatomic, retain)  NSMutableDictionary *svcs;
@property (nonatomic, retain)  NSMutableDictionary *controls;
@property (nonatomic, retain)  NSMutableDictionary *datas;
@property (nonatomic, retain)  NSMutableDictionary *busys;
@property (nonatomic, retain)  NSMutableDictionary *titles;
@property (nonatomic, retain) IBOutlet NSView *view;

@property (nonatomic, retain) WPAMainController *mainControl;
@property (nonatomic, retain) NSString *framePos; // hack since auto frame save is buggy for mysterious reasons
@property (nonatomic, retain) NSView *currentTaskView; 
@property (nonatomic, retain) TotalsManager *totalsManager; 
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) NSUInteger sizedCount;
@property (nonatomic) BOOL viewChanged;
@property (nonatomic, retain) NSTimer *buildTimer;
@property (nonatomic) NSRect saveRect;
@property (nonatomic) BOOL oneLastTime;
@property (nonatomic) BOOL useCache;

- (SummaryViewController*) getViewForInstance: (id<Reporter>) inst width: (CGFloat) vWidth rows: (int) nRows;

- (void) buildDisplay;

- (CGFloat) calcHeight;
@end

@interface TitleView : NSView {
	NSFont *font;
	NSString *titleStr;
	NSRect saveFrame;
	NSImage *altImage;
}
@property (nonatomic, retain) NSFont *font;
@property (nonatomic, retain) NSString *titleStr;
@property (nonatomic, retain) NSImage *altImage;
@property (nonatomic, assign) NSRect saveFrame;
@end

