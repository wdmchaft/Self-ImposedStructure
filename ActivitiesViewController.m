//
//  ActivitiesViewController.m
//  WorkPlayAway
//
//  Created by Charles on 7/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "ActivitiesViewController.h"
#import "WPADelegate.h"
#import "ColorWellCell.h"

@implementation ActivitiesViewController
@synthesize pieData, pieChart, busyInd, actTable, actTitle, activityChart;

- (void) refreshView
{
	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	if (activityChart == nil){
		activityChart = [[ActivityChart alloc]init];
		activityChart.chart = pieChart;
		[pieChart setDelegate:activityChart];
		[pieChart setDataSource:activityChart];
		activityChart.busy =busyInd;
		activityChart.title = actTitle;
		[actTable setDataSource:activityChart];	
		NSTableColumn *col = [[actTable tableColumns] objectAtIndex:0];
		[col setDataCell:[ColorWellCell new]];
	}

    [activityChart runQueryStarting:[NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)] 
							 ending:[NSDate date] 
						withContext:nad.managedObjectContext];
    [pieChart reloadData];
    [pieChart refreshDisplay:self];

	[busyInd startAnimation:self];
}

@end
