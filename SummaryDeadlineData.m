//
//  SummaryDeadlineData.m
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
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
	else if  ([colName isEqualToString:@"COL2"]){
		NSDate *due = (NSDate*) [params objectForKey:@"due_time"];
		theValue = [Utility shortTimeStrFor:due];
	} else {
		theValue = [params objectForKey:@"name"];
	}
	
	return theValue;
}

- (void) sort
{
	NSSortDescriptor *dueDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"due_time"
								 ascending:YES
								  selector:@selector(compare:)] ;
	NSArray *descriptors = [NSArray arrayWithObjects:dueDescriptor,nil];
	[data sortUsingDescriptors:descriptors];
}
@end
