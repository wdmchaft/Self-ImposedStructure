//
//  RepeatRule.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RepeatByDayType.h"


enum  _RepeatRuleType {
   RepeatDaily,
    RepeatWeekly,
    RepeatMonthly,
    RepeatYearly
} ;

typedef enum _RepeatRuleType FrequencyType;
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
- (id) initFromString:(NSString *)ruleStr;
@end
