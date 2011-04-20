//
//  SummaryStatsViewController.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SummaryStatusViewController.h"


@implementation SummaryStatusViewController
@synthesize startDate; 
@synthesize totalDays; 
@synthesize totalWorkDays; 
@synthesize averageWorkDay; 
@synthesize totalGoalHitDays; 
@synthesize percentGoalHitDays; 
@synthesize averageGoalHours; 
@synthesize ctrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (void) loadView
{
    [super loadView];
}
- (void)dealloc
{
    [super dealloc];
}
- (void) setup
{
   // [ctrl fetchPredicate];
   BOOL set = [ctrl setSelectionIndex:0];
    NSLog(@"set = %d", set);
    id something = ctrl.content;
    NSLog(@"content = %@", something);
}
@end
