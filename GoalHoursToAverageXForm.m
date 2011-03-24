//
//  MyClass.m
//  WorkPlayAway
//
//  Created by Charles on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoalHoursToAverageXForm.h"
#import "Context.h"
#import "TotalsManager.h"
#import "SummaryRecord.h"

@implementation GoalHoursToAverageXForm

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
+ (Class)transformedValueClass {
    return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSLog(@"value = %@", value);
    NSNumber *goalTime = value;
    Context *ctx = [Context sharedContext];
    
    TotalsManager *totalsMgr = ctx.totalsManager;
    SummaryRecord *summary = totalsMgr.summary;
    NSUInteger workTime = summary.timeWorked.intValue;
    if (workTime == 0)
        return nil;
    double ret;
    ret = goalTime.doubleValue /  workTime / 60 / 60;
    return [NSNumber numberWithDouble:ret];
    
}

@end
