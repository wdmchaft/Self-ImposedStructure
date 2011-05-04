//
//  SummaryTable.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/10/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SummaryTable.h"
#import "StatsRecord.h"

@implementation SummaryTable
@synthesize statData;
- (id) initWithRows: (NSArray*) data
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
	NSString *colName = (NSString*) [tableColumn identifier];
	////NSLog(@"row = %d colName = %@", row, colName);
	if ([colName isEqualToString:ACTIVITY_COL]){
		theValue = record.activity;
		//	theValue = @"test";
	}
	if ([colName isEqualToString:TODAY_COL]){
		theValue = [super formatTimePeriod:record.today];
	}
	if ([colName isEqualToString:CUR_WEEK_COL]){
		theValue = [super formatTimePeriod:record.week];
	}
	if ([colName isEqualToString:CUR_MONTH_COL]){
		theValue = [super formatTimePeriod:record.month];
	}
	if ([colName isEqualToString:CUR_HOUR_COL]){
		theValue = [super formatTimePeriod:record.hour];
	}
    return theValue;	
}

@end
