//
//  SummaryDeadlineData.m
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryDeadlineData.h"
#import "Utility.h"


@implementation SummaryDeadlineData


- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [data count]);
    NSDictionary *params  = [data objectAtIndex:row];
	NSString *colName = [tableColumn identifier];
	if ([colName isEqualToString:@"COL1"])
	{
		theValue = [NSNumber numberWithInt:0];
	}
	else {
		NSDate *due = (NSDate*) [params objectForKey:@"due_time"];
		NSString *dateStr = [Utility timeStrFor:due];
		theValue  = [NSString stringWithFormat:@"[%@] %@",dateStr, (NSString*)[params objectForKey:@"name"]];
	}
	
	return theValue;
}


@end
