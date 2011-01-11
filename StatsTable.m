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
@synthesize statData;
- (id) initWithData: (NSMutableArray*) data
{
	if (self)
	{
		//WPADelegate *wpa = (WPADelegate*)[NSApplication sharedApplication].delegate;
		//statData = [Schema statsReportForDate:[NSDate date] inContext:wpa.managedObjectContext];
		statData = data;
	}
	return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [statData count];
}


- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [statData count]);
    StatsRecord *record  = [statData objectAtIndex:row];
	NSObject *test = [statData objectAtIndex:row];
	//NSLog(@"object is %@", [[test class] description]);
	NSString *colName = (NSString*) [tableColumn identifier];
	//NSLog(@"row = %d colName = %@", row, colName);
	if ([colName isEqualToString:ACTIVITY_COL]){
		theValue = record.activity;
		//	theValue = @"test";
	}
	if ([colName isEqualToString:TODAY_COL]){
		theValue = [StatsTable formatTimePeriod:record.today];
	}
	if ([colName isEqualToString:CUR_WEEK_COL]){
		theValue = [StatsTable formatTimePeriod:record.week];
	}
	if ([colName isEqualToString:CUR_MONTH_COL]){
		theValue = [StatsTable formatTimePeriod:record.month];
	}
	if ([colName isEqualToString:CUR_HOUR_COL]){
		theValue = [StatsTable formatTimePeriod:record.hour];
	}
    return theValue;	
}

+(NSString*) formatTimePeriod: (NSTimeInterval) interval
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
