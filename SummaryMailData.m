//
//  SummaryMailData.m
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryMailData.h"
#import "Utility.h"

@implementation SummaryMailData

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [data count]);
    NSDictionary *params  = [data objectAtIndex:row];
	theValue = [params objectForKey:@"email"];
	NSString *colName = [tableColumn identifier];
	if ([colName isEqualToString:@"COL1"])
	{
		theValue = [params objectForKey:@"email"];
	}
	else if  ([colName isEqualToString:@"COL2"]){
		NSDate *due = (NSDate*) [params objectForKey:@"issued"];
		theValue = [Utility shortTimeStrFor:due];
	} else {
		theValue = [params objectForKey:@"summary"];
	}
    return theValue;
}

- (void) sort
{
	if ([data count] > 0 ){
		NSSortDescriptor *dueDescriptor =
		[[NSSortDescriptor alloc] initWithKey:@"issued"
									 ascending:YES];
		NSArray *descriptors = [NSArray arrayWithObjects:dueDescriptor,nil];
		[data sortUsingDescriptors:descriptors];
	}
}

@end
