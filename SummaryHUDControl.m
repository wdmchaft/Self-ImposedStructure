//
//  SummaryHudControl.m
//  WorkPlayAway
//
//  Created by Charles on 1/18/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryHUDControl.h"
#import "WPADelegate.h"
#import "Context.h"
#import "TaskList.h"
#import "Instance.h"
#import "Reporter.h"
#import <BGHUDAppKit/BGHUDAppKit.h>
#import "SummaryViewController.h"

@implementation SummaryHUDControl
@synthesize views;
@synthesize controls;
@synthesize label1, label2, label3, label4, label5, label6;

@synthesize mainControl;

@synthesize view;
@synthesize viewsBuilt, visibleCount;

- (void) showWindow:(id)sender
{
	[super showWindow:sender];
	NSDateFormatter *fmttr = [NSDateFormatter new];
	[fmttr setDateStyle:NSDateFormatterMediumStyle];
	[fmttr setTimeStyle:NSDateFormatterShortStyle];
	[super.window setTitle:[fmttr stringForObjectValue:[NSDate date]]];
	mainControl = sender; 
	[super.window makeKeyAndOrderFront:nil];
	[super.window center];
	[self buildDisplay];
}

- (void) windowDidLoad
{
	[super.window makeKeyAndOrderFront:nil];
	
}
- (NSTextField*) labelForIdx: (int) idx
{
	switch (idx) {
		case 0:
			return label1;
			break;
		case 1:
			return label2;
			break;
		case 2:
			return label3;
			break;
		case 3:
			return label4;
			break;
		case 4:
			return label5;
			break;
		case 5:
			return label6;
			break;
	}
	return nil;
}

#define LINE_HGT 20
#define PADDING 20
- (void) buildDisplay
{
	viewsBuilt = 0;
	int modulesHeight = 0;
	NSArray *settings = [[Context sharedContext].hudSettings allEnabled];
	for (HUDSetting *set in settings){
		modulesHeight += set.height * LINE_HGT;
	}
	NSMutableArray *tabTemp = [[NSMutableArray alloc]initWithCapacity:[settings count]];
	NSMutableArray *ctrlTemp = [[NSMutableArray alloc]initWithCapacity:[settings count]];
	NSRect currRect = [[super window] frame];
	currRect.size.height = modulesHeight + (([settings count]) * PADDING)+ 30 ; // 15 each for top & bottom of frame	
	[[super window] setFrame: currRect display:YES];
	int count = 0;
	int totalHeight = 0;
	NSMutableArray *labelLocs = [NSMutableArray new];
	for (int i = [settings count] - 1;i >= 0;i--){
		
		HUDSetting *setting = [settings objectAtIndex:i];
		
		id<Reporter> rpt = setting.reporter; 
		NSRect tableFrame;
		int currHeight = setting.height * LINE_HGT;
		tableFrame.origin.y = PADDING/2 + totalHeight;
		tableFrame.origin.x = 5;
		tableFrame.size.width = currRect.size.width - 10;
		tableFrame.size.height = currHeight+14;
		
		[labelLocs addObject: [NSNumber numberWithInt:tableFrame.origin.y + tableFrame.size.height]];
		
		NSRect busyFrame;
		busyFrame.origin.y = tableFrame.origin.y + (tableFrame.size.height / 2) - 16;
		busyFrame.origin.x = tableFrame.origin.x + (tableFrame.size.width / 2) - 16;
		NSProgressIndicator *progInd = [[BGHUDProgressIndicator alloc] initWithFrame:busyFrame];
		[progInd setStyle:NSProgressIndicatorSpinningStyle];
		[progInd sizeToFit];
		[progInd setHidden:YES];
		NSBox *box = [[BGHUDBox alloc] initWithFrame:tableFrame];
		[view addSubview:box];
		[view addSubview:progInd];
		NSSize margins; margins.height = 0; margins.width = 0;
		[box setContentViewMargins:margins];
		[box setBorderType:NSNoBorder];
		box.titlePosition = NSNoTitle;
		SummaryViewController *svc = [self getViewForInstance:rpt view: box.contentView rows: setting.height];
		svc.prog = progInd;
		[svc.view setFrame:[box.contentView bounds]];	
		[ctrlTemp addObject:svc];
		[box setContentView: svc.view];
		[box setFrameFromContentFrame:tableFrame];
		//[box sizeToFit];
		totalHeight += currHeight + PADDING/2;
		[NSTimer scheduledTimerWithTimeInterval:0 target:svc selector:@selector(refresh) userInfo: nil repeats:NO];
		
		[tabTemp addObject: box];
	}
	// draw titles after the boxes so that they aren't overwritten and hidden.
	count = 0;
	for (int j = [settings count] - 1;j >= 0;j--){
		NSNumber *loc = [labelLocs objectAtIndex:count];
		HUDSetting *setting = [settings objectAtIndex:j];
		NSPoint labelLoc;
		labelLoc.y = loc.intValue;
		labelLoc.x =10;
		NSTextField *label = [self labelForIdx:count];
		[label setFrameOrigin:labelLoc];
		[label setStringValue: setting.label];
		NSLog(@"label = %@", setting.label);
		[label setHidden:NO];
		[label sizeToFit];
		count++;
	}
	views = [[NSArray alloc] initWithArray:tabTemp];
	controls = [[NSArray alloc] initWithArray:ctrlTemp];
}

- (void) refreshDisplay
{
	int modulesHeight = 0;
	for (SummaryViewController *svc in controls){
		modulesHeight += [svc actualHeight];
	}
//	NSMutableArray *tabTemp = [[NSMutableArray alloc]initWithCapacity:[settings count]];
	NSRect currRect = [[super window] frame];
	currRect.size.height = modulesHeight + ((visibleCount+1) * PADDING)+ 15 ; // 15 for top & bottom of frame	
	[[super window] setFrame: currRect display:YES];
    NSRect mainRect = [[NSScreen mainScreen] frame];
    CGFloat mainX = (mainRect.size.width / 2) - (currRect.size.width / 2);
    CGFloat mainY = (mainRect.size.height / 2) - (currRect.size.height / 2);
    [[super window] setFrameOrigin: NSMakePoint(mainX,mainY)];
	int count = 0;
	int totalHeight = PADDING;
	NSMutableArray *labelLocs = [NSMutableArray new];
	for (int i = [controls count] - 1;i >= 0;i--){
		
		SummaryViewController *svc = [controls objectAtIndex:i];
        NSView *boxView = [[svc view] superview];
        if (svc.actualLines == 0) {
            [boxView setHidden:YES];
			break;
        }
		
		NSRect tableFrame;
		int currHeight = [svc actualHeight];
		tableFrame.origin.y = totalHeight;
		tableFrame.origin.x = 5;
		tableFrame.size.width = currRect.size.width - 10;
		tableFrame.size.height = currHeight;
		
		[labelLocs addObject: [NSNumber numberWithInt:tableFrame.origin.y + tableFrame.size.height]];
		
		NSRect busyFrame;
		busyFrame.origin.y = tableFrame.origin.y + (tableFrame.size.height / 2) - 16;
		busyFrame.origin.x = tableFrame.origin.x + (tableFrame.size.width / 2) - 16;
		NSProgressIndicator *progInd = [[BGHUDProgressIndicator alloc] initWithFrame:busyFrame];
		[progInd setStyle:NSProgressIndicatorSpinningStyle];
		[progInd sizeToFit];
		[progInd setHidden:YES];
		[boxView setFrame:tableFrame];

		[svc.view setFrame:[boxView bounds]];	

		totalHeight += currHeight + PADDING;
	}
    for (int k = 0; k < 6; k++){
        NSTextField *l = [self labelForIdx:k];
        [l setHidden:YES];
    }
	// draw titles after the boxes so that they aren't overwritten and hidden.
    HUDSettings *settings = [Context sharedContext].hudSettings;
	count = 0;
	for (int j = [controls count] - 1;j >= 0;j--){
		NSTextField *label = [self labelForIdx:count];
		[label setHidden: YES];
		SummaryViewController *svc = [controls objectAtIndex:j];
		if (svc.actualLines == 0)
			break;
		NSNumber *loc = [labelLocs objectAtIndex:count];
		NSPoint labelLoc;
		labelLoc.y = loc.intValue;
		labelLoc.x =10;
        [label setStringValue: [settings labelForInstance:svc.reporter]];
        [label setFrameOrigin:labelLoc];
		[label setHidden:NO];
		[label sizeToFit];
		count++;
	}
}

- (void) viewSized: (SummaryViewController*) svc
{
	NSArray *settings = [[Context sharedContext].hudSettings allEnabled];
	viewsBuilt++;
	visibleCount += (svc.actualLines > 0);
	if (viewsBuilt == [settings count]){
		[self refreshDisplay];
	}
}

- (SummaryViewController*) getViewForInstance: (id<Reporter>) inst view: (NSView*) box rows: (int) nRows
{
	NSString *rptNib;
	NSRect sbounds = box.bounds;
	NSRect sframe = box.frame;
	NSLog(@"bounds = h:%f w:%f", sbounds.size.height, sbounds.size.width);
	NSLog(@"frame = h:%f w:%f", sframe.size.height, sframe.size.width);
	switch (inst.category) {
		case CATEGORY_EMAIL:
			rptNib = @"MailTableView";
			return [[SummaryMailViewController alloc] initWithNibName: rptNib 
															   bundle:[NSBundle mainBundle] 
															   module:inst
																 rows: nRows
																 width: sbounds.size.width
															   caller:self];
			break;
		case CATEGORY_TASKS:
			rptNib = @"TaskTableView";
			return [[SummaryTaskViewController alloc] initWithNibName: rptNib 
															   bundle:[NSBundle mainBundle] 
															   module:inst
																 rows: nRows
																width: sbounds.size.width															   
															   caller:self];
	break;
		case CATEGORY_EVENTS:
			rptNib = @"EventTableView";
			return [[SummaryEventViewController alloc] initWithNibName: rptNib 
																bundle:[NSBundle mainBundle] 
																module:inst
																  rows: nRows
																 width: sbounds.size.width																
																caller:self];
		break;
		default:
			break;	
	}
	return nil;
}

@end
