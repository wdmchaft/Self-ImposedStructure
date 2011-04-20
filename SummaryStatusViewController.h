//
//  SummaryStatsViewController.h
//  Self-Imposed Structure
//
//  Created by Charles on 3/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SummaryStatusViewController : NSViewController {
@private
    NSTextField *startDate; 
    NSTextField *totalDays; 
    NSTextField *totalWorkDays; 
    NSTextField *averageWorkDay; 
    NSTextField *totalGoalHitDays; 
    NSTextField *percentGoalHitDays; 
    NSTextField *averageGoalHours; 
    NSArrayController *ctrl;
}
@property (nonatomic,retain) IBOutlet NSTextField *startDate;
@property (nonatomic,retain) IBOutlet NSTextField *totalDays;
@property (nonatomic,retain) IBOutlet NSTextField *totalWorkDays;
@property (nonatomic,retain) IBOutlet NSTextField *averageWorkDay;
@property (nonatomic,retain) IBOutlet NSTextField *totalGoalHitDays;
@property (nonatomic,retain) IBOutlet NSTextField *percentGoalHitDays;
@property (nonatomic,retain) IBOutlet NSTextField *averageGoalHours;
@property (nonatomic,retain) IBOutlet NSArrayController *ctrl;
- (IBAction) setup;

@end

