//
//  WorkHoursToAverageXForm.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "WorkHoursToAverageXForm.h"
#import "Context.h"
#import "TotalsManager.h"

@implementation WorkHoursToAverageXForm

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
    NSNumber *workTime = value;
    Context *ctx = [Context sharedContext];
    
    TotalsManager *totalsMgr = ctx.totalsManager;
    SummaryRecord *summary = totalsMgr.summary;
    NSUInteger daysWorked = summary.daysWorked.intValue;
    if (workTime.intValue == 0)
        return nil;
    double ret;
    ret = workTime.doubleValue /  daysWorked / 60 / 60;
    return [NSNumber numberWithDouble:ret];
    
}


@end
