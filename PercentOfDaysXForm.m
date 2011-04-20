//
//  PercentOfDaysXForm.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "PercentOfDaysXForm.h"
#import "Context.h"
#import "TotalsManager.h"

@implementation PercentOfDaysXForm

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
    NSNumber *daysHitGoal = value;
    Context *ctx = [Context sharedContext];
    
    TotalsManager *totalsMgr = ctx.totalsManager;
    SummaryRecord *summary = totalsMgr.summary;
    NSUInteger daysWorked = summary.daysWorked.intValue;
    if (daysWorked == 0)
        return nil;
    double ret;
    ret = daysHitGoal.doubleValue /  daysWorked / 60 / 60;
    return [NSNumber numberWithDouble:ret];
    
}
@end
