//
//  WorkTable.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/10/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "WorkTable.h"
#import "StatsRecord.h"

@implementation WorkTable
@synthesize workData;
- (id) initWithRows: (NSArray*) data
{
	if (self)
	{
		workData = data;
	}
	return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [workData count];
}


- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [workData count]);
    StatsRecord *record  = [workData objectAtIndex:row];
	NSString *colName = (NSString*) [tableColumn identifier];
	////NSLog(@"row = %d colName = %@", row, colName);
	if ([colName isEqualToString:TASK_COL]){
		theValue = record.task;
	}if ([colName isEqualToString:SOURCE_COL]){
		theValue = record.source;
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
