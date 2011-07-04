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

@interface MyButtonCell	: NSButtonCell
{
}
@end

@interface SummaryHUDControl :  NSWindowController <NSWindowDelegate, SummaryHUDCallback, NSSplitViewDelegate> 
{
	WPAMainController *mainControl;
 
	NSString *framePos;
	NSTimer *buildTimer;
	NSRect saveRect;
	NSView *header;
	NSTextView *goalText;
	TotalsManager *totalsManager;
	NSSplitView *splitter;
	NSMutableDictionary *datas;
	NSMutableDictionary *busys;
	NSMutableDictionary *cells;
	BOOL doingBuild;
	NSUInteger renderedViews;
	CGFloat viewsHeight;
	BOOL useCache;
	NSButton	 *taskField;
	NSTextField *timeField;
}

@property (nonatomic, retain) WPAMainController *mainControl;
@property (nonatomic, retain) NSString *framePos; // hack since auto frame save is buggy for mysterious reasons
@property (nonatomic, retain) NSView *currentTaskView; 
@property (nonatomic, retain) TotalsManager *totalsManager; 
@property (nonatomic, retain) IBOutlet NSSplitView *splitter; 
@property (nonatomic, retain) IBOutlet NSView *header; 
@property (nonatomic) NSRect saveRect;
@property (nonatomic, retain) NSMutableDictionary *datas;
@property (nonatomic, retain) NSMutableDictionary *busys;
@property (nonatomic, retain) NSMutableDictionary *cells;
@property (nonatomic) BOOL doingBuild;
@property (nonatomic) NSUInteger renderedViews;
@property (nonatomic) CGFloat viewsHeight;
@property (nonatomic) BOOL useCache;
@property (nonatomic, retain) IBOutlet NSButton *taskField;
@property (nonatomic, retain) IBOutlet NSTextField *timeField;
- (void) buildDisplay;
- (IBAction) showSwitchActivity: (id) sender;


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

