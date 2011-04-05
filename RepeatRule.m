//
//  RepeatRule.m
//  WorkPlayAway
//
//  Created by Charles on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepeatRule.h"


@implementation RepeatRule
@synthesize isEvery, interval, frequency,byDays,byMonthDays;
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

- (FrequencyType) typeFromString:(NSString*) typeStr
{
    if ([typeStr isEqualToString:@"DAILY"])
        return RepeatDaily;
    if ([typeStr isEqualToString:@"MONTHLY"])
        return RepeatMonthly;
    if ([typeStr isEqualToString:@"YEARLY"])
        return RepeatYearly;
    if ([typeStr isEqualToString:@"WEEKLY"])
        return RepeatWeekly;
    NSAssert1(1 == 0, @"Unrecognized repeat type: %@", typeStr);
    return -1;
}
- (DayOfWeekType) dayFromString:(NSString*) typeStr
{
    if ([typeStr isEqualToString:@"SU"])
        return Sunday;
    if ([typeStr isEqualToString:@"MO"])
        return Monday;
    if ([typeStr isEqualToString:@"TU"])
        return Tuesday;
    if ([typeStr isEqualToString:@"WE"])
        return Wednesday;
    if ([typeStr isEqualToString:@"TH"])
        return Thursday;
    if ([typeStr isEqualToString:@"FR"])
        return Friday;
    if ([typeStr isEqualToString:@"SA"])
        return Saturday;
    NSAssert1(1 == 0, @"Unrecognized dayx type: %@", typeStr);
    return -1;
}

- (id) initFromString: (NSString*) rule
{
    if (self) {
        NSScanner *scanner = [NSScanner localizedScannerWithString:rule];
        [scanner scanUpToString:@"FREQ=" intoString:nil];
        NSString *temp = nil;
        [scanner scanUpToString:@";" intoString:&temp ];
        frequency = [self typeFromString:temp];
    
        [scanner scanUpToString:@"INTERVAL=" intoString:nil];
        NSAssert([scanner scanInt:&interval] == YES, @"Bad Interval");
        [scanner setScanLocation:[scanner scanLocation]+1]; // skip semi-colon
        [scanner scanUpToString:@"=" intoString:&temp];
        if ([temp isEqualToString:@"BYDAY"]){
            NSMutableArray *tempAry = [NSMutableArray new];
            [scanner setScanLocation:[scanner scanLocation]+1]; //skip equal
            NSUInteger pos = [scanner scanLocation];
            while ([scanner scanUpToString:@"," intoString:&temp]) {
                [scanner setScanLocation: pos];
                ByDay *byDay = [ByDay new];
                byDay.numerator= 1;
                int intTemp = 1;
                [scanner scanInt:&intTemp];
                byDay.numerator = intTemp;
                [scanner scanUpToString:@"," intoString:&temp];
                byDay.day = [self dayFromString: temp];
                [tempAry addObject:byDay];
                pos =[scanner scanLocation];
            }
            byDays = [NSArray arrayWithArray:tempAry];
        }
        else if ([temp isEqualToString:@"BYMONTHDAY"]){
            NSMutableArray *tempAry = [NSMutableArray new];
            [scanner setScanLocation:[scanner scanLocation]+1]; // skip equal
            int intTemp = 1;
            NSUInteger pos = [scanner scanLocation];
            while ([scanner scanUpToString:@"," intoString:&temp]) {
                [scanner setScanLocation: pos];
                [scanner scanInt:&intTemp];
                NSNumber *num = [NSNumber numberWithInt:intTemp];
                [tempAry addObject:num];
            }
            byMonthDays = [NSArray arrayWithArray:tempAry];
        }
    }
    return self;
}

@end
