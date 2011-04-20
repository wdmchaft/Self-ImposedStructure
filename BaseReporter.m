//
//  BaseReporter.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "BaseReporter.h"


@implementation BaseReporter
@synthesize summaryTitle;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic name;
@dynamic category;
- (void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary{}
- (void) initSummaryTable: (NSTableView*) view{}
- (void) handleClick:(NSDictionary *)params{}
@end


