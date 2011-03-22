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
@synthesize controls,progs, boxes;
@synthesize lineHeight;
@synthesize mainControl;

@synthesize view;
@synthesize hudList;

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

#define LINE_HGT 20
#define PADDING 20
/*** 
 the display is just a stack of nsboxes containing tables.  each table has a maximum size, but if there are fewer 
 rows it could be smaller. and if the table is empty then it will not display nor will its surrounding box.
 buildDisplay will launch the summaryviewcontrollers for each table.  Each time the controllers either get an initial response or are complete the refreshDisplay method is called.
 ***/

- (void) buildDisplay 
{
	NSRect currRect = [[super window] frame];
	NSArray *settings = [[Context sharedContext].hudSettings allEnabled];
    // build it from the bottom of the list up because of the way screen coordinates work in cocoa
	NSRect winRect = [[super window] frame];
    CGFloat viewWidth = winRect.size.width - 10;
	if (controls == nil){
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[settings count]];
        NSMutableArray *tempP = [NSMutableArray arrayWithCapacity:[settings count]];
        NSMutableArray *tempB = [NSMutableArray arrayWithCapacity:[settings count]];
        for (int i = [settings count] - 1;i >= 0;i--){
            HUDSetting *setting = [settings objectAtIndex:i];
            id<Reporter> rpt = setting.reporter; 
            SummaryViewController *svc = [self getViewForInstance:rpt width:viewWidth rows:setting.height];
            [temp addObject :svc];
            NSProgressIndicator *progInd = [[BGHUDProgressIndicator alloc] initWithFrame:winRect];
            [progInd setStyle:NSProgressIndicatorSpinningStyle]; 
            [progInd setControlSize:NSSmallControlSize];
            svc.prog = progInd;
            [tempP addObject:progInd];
            NSBox *box = [[BGHUDBox alloc] initWithFrame:winRect];
            NSSize margins; margins.height = 0; margins.width = 0;
            [box setContentViewMargins:margins];
            [tempB addObject:box];
            [box setContentView:svc.view];
            NSDictionary *attrs = [NSDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
            NSString *titleStr = [[NSAttributedString alloc]initWithString:setting.label 
                                               attributes:attrs];
            [box setTitle:titleStr];
            [box setTitlePosition:NSAboveTop];
            [box setBoxType:NSBoxSecondary];
            [view addSubview:box];
            [view addSubview:progInd];
            // lastly -- start the view controller
            [NSTimer scheduledTimerWithTimeInterval:0 target:svc selector:@selector(refresh) userInfo: nil repeats:NO];
      }   
        controls = [[NSArray alloc]initWithArray:temp];
        progs = [[NSArray alloc] initWithArray:tempP];
        boxes = [[NSArray alloc] initWithArray:tempB];
    }
    CGFloat totalHeight = lineHeight;
	for (int i = [controls count] - 1;i >= 0;i--){
		
		SummaryViewController *svc = [controls objectAtIndex:i];
        NSBox *boxView = [boxes objectAtIndex:i];
        NSProgressIndicator *progView = [progs objectAtIndex:i];
        if (svc.actualLines == 0) {
            [boxView setHidden:YES];
            [svc.table setHidden:YES];
            [progView setHidden:YES];
        }
		else {
            [boxView setHidden:NO];
            [svc.table setHidden:NO];
            NSRect boxFrame;
            lineHeight = [svc.table rowHeight];
            boxFrame.origin.y = totalHeight;
            boxFrame.origin.x = 5;
            boxFrame.size.width = winRect.size.width - 10;
            boxFrame.size.height = [svc actualHeight] + (lineHeight * 2);
            
            
            NSRect busyFrame;
            busyFrame.origin.y = boxFrame.origin.y + (boxFrame.size.height / 2) - 16;
            busyFrame.origin.x = boxFrame.origin.x + (boxFrame.size.width / 2) - 16;
            [progView setFrame:busyFrame];
            [progView sizeToFit];
                
   //         [boxView setFrame:boxFrame];

            NSRect contentFrame = boxFrame;
            contentFrame.size.height = [svc actualHeight];
            [boxView setFrameFromContentFrame:contentFrame];
            
            [svc.view setFrame:[boxView.contentView bounds]];	
            
            totalHeight += boxFrame.size.height;
        }
	}
    totalHeight += lineHeight;
	currRect.size.height = totalHeight;	
	[[super window] setContentSize: currRect.size];
//	currRect.size.height += 15; // for titlebar height	
	[[super window] setFrame: currRect display:YES];
    NSRect mRect = [NSScreen mainScreen].frame;
    CGFloat oX = (mRect.size.width / 2) - (currRect.size.width / 2);
    CGFloat oY = (mRect.size.height / 2) - (currRect.size.height / 2);
    [[super window] setFrameOrigin:NSMakePoint(oX, oY)];
}


- (void) viewSized
{
    [self buildDisplay];
}

- (SummaryViewController*) getViewForInstance: (id<Reporter>) inst width: (CGFloat) vWidth rows: (int) nRows
{
	NSString *rptNib;

	switch (inst.category) {
		case CATEGORY_EMAIL:
			rptNib = @"MailTableView";
			return [[SummaryMailViewController alloc] initWithNibName: rptNib 
															   bundle:[NSBundle mainBundle] 
															   module:inst
																 rows: nRows
                                                             waitRows: 2
																 width: vWidth 
															   caller:self];
			break;
		case CATEGORY_TASKS:
			rptNib = @"TaskTableView";
			return [[SummaryTaskViewController alloc] initWithNibName: rptNib 
															   bundle:[NSBundle mainBundle] 
															   module:inst
																 rows: nRows
                                                             waitRows: 2
																width: vWidth											   
															   caller:self];
	break;
		case CATEGORY_EVENTS:
			rptNib = @"EventTableView";
			return [[SummaryEventViewController alloc] initWithNibName: rptNib 
																bundle:[NSBundle mainBundle] 
																module:inst
																  rows: nRows
                                                              waitRows: 2
																 width:  vWidth											
																caller:self];
		break;
		default:
			break;	
	}
	return nil;
}

@end
