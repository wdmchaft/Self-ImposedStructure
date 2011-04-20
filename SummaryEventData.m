//
//  SummaryEventData.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SummaryEventData.h"
#import "Utility.h"
#import "Reporter.h"


@implementation SummaryEventData

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
	NSParameterAssert(row >= 0 && row < [data count]);
    NSDictionary *params  = [data objectAtIndex:row];
	NSString *colName = [tableColumn identifier];
	if ([colName isEqualToString:@"COL1"]){
		NSDate *starts = [params objectForKey:@"start"];
		theValue = [Utility shortTimeStrFor:starts];
	} else {
		theValue = [params objectForKey:EVENT_SUMMARY];
	}
	

    return theValue;
}
- (void) sort
{
	NSSortDescriptor *dueDescriptor =
    [[NSSortDescriptor alloc] initWithKey:EVENT_START
								 ascending:YES
								  selector:@selector(compare:)];
	NSArray *descriptors = [NSArray arrayWithObjects:dueDescriptor,nil];
	[data sortUsingDescriptors:descriptors];
}
@end
