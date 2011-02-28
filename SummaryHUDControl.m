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
@synthesize modules;
@synthesize heights;
@synthesize views;

@synthesize mainControl;

@synthesize view;

- (id) initWithWindowNibName: (NSString*) nibNameOrNil  
{
	self = [super initWithWindowNibName:nibNameOrNil];
	if (self)
	{
		NSMutableArray *tHeights = [NSMutableArray new];
		NSMutableArray *runMods = [NSMutableArray new];
		for (NSString *modName in [Context sharedContext].instancesMap){
			<Reporter> module = [[Context sharedContext].instancesMap objectForKey:modName];
			if (module.enabled && [(id)module conformsToProtocol:@protocol(Reporter) ] ){
				[runMods addObject:module];
				[tHeights addObject: [NSNumber numberWithInt:100]];
			}
		}
		modules = runMods;
		heights = [NSArray arrayWithArray:tHeights];
	}
	return self;
}




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

#define PADDING 10
- (void) buildDisplay
{
	int modulesHeight = 0;
	for (NSNumber *n in heights){
		modulesHeight += n.intValue;
	}
	NSMutableArray *tabTemp = [[NSMutableArray alloc]initWithCapacity:[modules count]];
	NSRect currRect = [[super window] frame];
	currRect.size.height = modulesHeight + (([modules count]) * PADDING)+ 15 ; // 15 for top of frame	
	[[super window] setFrame: currRect display:YES];
	int count = 0;
	int totalHeight = PADDING;
	NSEnumerator *modEnum = [modules reverseObjectEnumerator];
	for (<Reporter> rpt in modEnum){
		NSRect tableFrame;
		int currHeight = ((NSNumber*)[heights objectAtIndex:count]).intValue;
		tableFrame.origin.y = PADDING/2 + totalHeight;
		tableFrame.origin.x = 5;
		tableFrame.size.width = currRect.size.width - 10;
		tableFrame.size.height = currHeight-20;
		NSRect busyFrame;
		busyFrame.origin.y = tableFrame.origin.y + (tableFrame.size.height / 2) - 16;
		busyFrame.origin.x = tableFrame.origin.x + (tableFrame.size.width / 2) - 16;
		NSProgressIndicator *progInd = [[NSProgressIndicator alloc] initWithFrame:busyFrame];
		[progInd setStyle:NSProgressIndicatorSpinningStyle];
		[progInd sizeToFit];
		[progInd setHidden:YES];
		NSBox *box = [[NSBox alloc] initWithFrame:tableFrame];
		[view addSubview:box];
		[view addSubview:progInd];
		[box setTitle: rpt.summaryTitle];
		NSSize margins; margins.height = 0; margins.width = 0;
		[box setContentViewMargins:margins];
		[box setBorderType:NSNoBorder];
		box.titlePosition = NSAboveTop;
		SummaryViewController *svc = [self getViewForInstance:rpt view: box.contentView];
		svc.prog = progInd;
		[svc.view setFrame:[box.contentView bounds]];	
		[box setContentView: svc.view];
		[box setFrameFromContentFrame:tableFrame];
		//[box sizeToFit];
		totalHeight += currHeight + PADDING/2;
		[NSTimer scheduledTimerWithTimeInterval:0 target:svc selector:@selector(refresh) userInfo: nil repeats:NO];

		[tabTemp addObject: box];
	}
	views = [[NSArray alloc] initWithArray:tabTemp];
}

- (SummaryViewController*) getViewForInstance: (<Reporter>) inst view: (NSView*) box
{
	NSString *rptNib;
	NSRect sbounds = box.bounds;
	NSRect sframe = box.frame;
	NSLog(@"bounds = h:%d w:%d", sbounds.size.height, sbounds.size.width);
	NSLog(@"frame = h:%d w:%d", sframe.size.height, sframe.size.width);
	switch (inst.category) {
		case CATEGORY_EMAIL:
			rptNib = @"MailTableView";
			return [[SummaryMailViewController alloc] initWithNibName: rptNib 
															   bundle:[NSBundle mainBundle] 
															   module:inst
																size: sbounds.size];
			break;
		case CATEGORY_TASKS:
			rptNib = @"TaskTableView";
			return [[SummaryTaskViewController alloc] initWithNibName: rptNib 
																   bundle:[NSBundle mainBundle] 
																   module:inst
																	 size:sbounds.size];
			break;
		case CATEGORY_EVENTS:
			rptNib = @"EventTableView";
			return [[SummaryEventViewController alloc] initWithNibName: rptNib 
																bundle:[NSBundle mainBundle] 
																module:inst
																  size:sbounds.size];
			break;
		default:
			break;	
	}
	return nil;
}


@end
