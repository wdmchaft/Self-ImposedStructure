//
//  StatsTable.m
//  WorkPlayAway
//
//  Created by Charles on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatsTable.h"
#import "StatsRecord.h"
#import "TimeDefines.h"
#import "WPADelegate.h"
#import "Schema.h"

@implementation StatsTable

-(NSString*) formatTimePeriod: (NSTimeInterval) interval
{
	NSUInteger secs = interval;
	NSUInteger mins = secs / SECSPERMIN;
	NSUInteger hrs = mins / MINPERHR;
	NSUInteger days = hrs / HRPERDAY;
	NSUInteger wks = days / DAYPERWK;
	NSString *weekStr = [[NSString alloc] initWithFormat:@"Week"];
	NSString *weeksStr = [[NSString alloc] initWithFormat:@"Weeks"];
	NSString *daysStr = [[NSString alloc] initWithFormat:@"Days"];
	NSString *dayStr = [[NSString alloc] initWithFormat:@"Day"];
	NSString *hoursStr = [[NSString alloc] initWithFormat:@"hrs"];
	NSString *hourStr = [[NSString alloc] initWithFormat:@"hr"];
	NSString *minsStr = [[NSString alloc] initWithFormat:@"min"];
	NSString *minStr = [[NSString alloc] initWithFormat:@"min"];
	NSString *retStr = [NSString new];
	if (wks > 1) {
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",wks, weeksStr,days, daysStr];
	}
	if (wks == 1) {
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",wks, weekStr,days, daysStr];
	}
	if (days > 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",days, daysStr,hrs, hoursStr];
	}
	if (days == 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",days, dayStr,hrs, hoursStr];
	}
	if (hrs > 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",hrs , hoursStr,mins, minsStr];
	}
	if (hrs == 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",hrs , hourStr, mins, minsStr];
	}
	retStr = [[NSString alloc] initWithFormat:@"%d %@", mins, minsStr];
	return retStr;
}
@end
