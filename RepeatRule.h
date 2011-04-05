//
//  RepeatRule.h
//  WorkPlayAway
//
//  Created by Charles on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
enum  _DayOfWeek {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
} ;

typedef enum _DayOfWeek DayOfWeekType;

enum  _RepeatRuleType {
   RepeatDaily,
    RepeatWeekly,
    RepeatMonthly,
    RepeatYearly
} ;

typedef enum _RepeatRuleType FrequencyType;

@interface ByDay : NSObject {
@private
    int numerator;
    DayOfWeekType day;
}
@property (nonatomic) int numerator;
@property (nonatomic) DayOfWeekType day;
@end
@implementation ByDay
@synthesize numerator, day;
@end

@interface RepeatRule : NSObject {
@private
    BOOL isEvery;
    int interval;
    FrequencyType frequency;
    NSArray *byDays;
    NSArray *byMonthDays;
}
@property (nonatomic) BOOL isEvery;
@property (nonatomic) int interval;
@property (nonatomic) FrequencyType frequency;
@property (nonatomic, retain) NSArray* byDays;
@property (nonatomic, retain) NSArray* byMonthDays;
@end
