//
//  SummaryEventData.m
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryEventData.h"
#import "Utility.h"


@implementation SummaryEventData

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [data count]);
    NSDictionary *params  = [data objectAtIndex:row];
	NSString *colName = [tableColumn identifier];
	if ([colName isEqualToString:@"COL1"]){
		NSDate *starts = [params objectForKey:@"starts"];
		theValue = [Utility shortTimeStrFor:starts];
	} else {
		theValue = [params objectForKey:@"summary"];
	}
	

    return theValue;
}
- (void) sort
{
	NSSortDescriptor *dueDescriptor =
    [[[NSSortDescriptor alloc] initWithKey:@"starts"
								 ascending:YES
								  selector:@selector(compare:)] autorelease];
	NSArray *descriptors = [NSArray arrayWithObjects:dueDescriptor,nil];
	data = [NSMutableArray arrayWithArray:[data sortedArrayUsingDescriptors:descriptors]];
}
@end
