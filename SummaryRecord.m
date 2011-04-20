//
//  SummaryRecord.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SummaryRecord.h"


@implementation SummaryRecord
@synthesize dateStart;
@synthesize dateWrite;
@synthesize timeTotal;
@synthesize timeWorked;
@synthesize daysTotal;
@synthesize daysWorked;
@synthesize timeGoal;
@synthesize daysGoalAchieved;
@synthesize lastDay, lastWorked, lastGoalAchieved;

- (id)init
{
    self = [super init];
    if (self) {
        [self setDateStart:[NSDate date]];
        [self setDateWrite:[[NSDate distantPast]copy]];
        
        [self setLastDay:[[NSDate distantPast]copy]];
        [self setLastWorked:[[NSDate distantPast]copy]];
        [self setLastGoalAchieved:[[NSDate distantPast]copy]];
        
        [self setDaysGoalAchieved:[NSNumber numberWithInt:0]];
        [self setDaysTotal:[NSNumber numberWithInt:0]];
        [self setDaysWorked:[NSNumber numberWithInt:0]];
        
        [self setTimeGoal:[NSNumber numberWithDouble:0]];
        [self setTimeWorked:[NSNumber numberWithDouble:0]];
        [self setTimeTotal:[NSNumber numberWithDouble:0]];
    }
    
    return self;
}

- (id) initWithEntity: (NSManagedObject*) summary
{
    if (self) {
        [self setDateStart:[summary valueForKey:@"dateStart"]];
        [self setDateWrite:[summary valueForKey:@"dateWrite"]];
        
        [self setDaysGoalAchieved:[summary valueForKey:@"daysGoalAchieved"]];
        [self setDaysTotal:[summary valueForKey:@"daysTotal"]];
        [self setDaysWorked:[summary valueForKey:@"daysWorked"]];
        
        [self setTimeGoal:[summary valueForKey:@"timeGoal"]];
        [self setTimeWorked:[summary valueForKey:@"timeWorked"]];
        [self setLastGoalAchieved:[summary valueForKey:@"lastGoalAchieved"]];
        
        [self setLastDay:[summary valueForKey:@"lastDay"]];
        [self setLastWorked:[summary valueForKey:@"lastWorked"]];
        [self setTimeTotal:[summary valueForKey:@"timeTotal"]];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
