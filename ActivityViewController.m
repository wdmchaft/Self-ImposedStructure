//
//  ActivityViewController.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/31/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "ActivityViewController.h"
#import "WPADelegate.h"
#import "ColorWellCell.h"

@implementation ActivityViewController
@synthesize pieChart, table, busyInd, activityChart;

- (void) awakeFromNib{
    NSLog(@"awaking AVC");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) loadView
{
    [super loadView];
	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	[busyInd setHidden:YES];
    activityChart = [[ActivityChart alloc]init];
    [activityChart runQueryStarting:[NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)] 
                             ending:[NSDate date] 
                        withContext:nad.managedObjectContext]; 
    
    NSTableColumn *col = [[table tableColumns] objectAtIndex: 0];
    [col setDataCell: [ColorWellCell new]];
    [table setDataSource:activityChart];
    [table setHidden:NO];
    activityChart.chart = pieChart;
    [pieChart setDelegate:activityChart];
    [pieChart setDataSource:activityChart];
    activityChart.busy =busyInd;
   
    [pieChart reloadData];
    [pieChart setHidden:NO];
    [pieChart refreshDisplay:self];


    [[super view] needsDisplay];
}

@end
