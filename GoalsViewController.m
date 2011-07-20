//
//  GoalsViewController.m
//  WorkPlayAway
//
//  Created by Charles on 7/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "GoalsViewController.h"
#import "WPADelegate.h"

@implementation GoalsViewController
@synthesize goalChart, barChart, prog;

- (void) awakeFromNib
{
	NSLog(@"awaking...");
}

- (void) refreshView
{
	[super refreshView];
	if (!goalChart) {
		goalChart = [[GoalChart alloc]init];
		goalChart.chart = barChart;
		goalChart.busy = prog;
		[barChart setDelegate: goalChart];
		[barChart setDataSource: goalChart];
		[ barChart setAxisInset:[ SM2DGraphView barWidth ] forAxis:kSM2DGraph_Axis_X ];
		[ barChart setLiveRefresh:YES ];
	}
	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	[prog startAnimation:self];
	[barChart setDataSource:goalChart];
	[goalChart runQueryStarting:[NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)] 
						 ending:[NSDate date] 
					withContext:nad.managedObjectContext];
	[barChart reloadData];
	[barChart reloadAttributes];
}

@end
