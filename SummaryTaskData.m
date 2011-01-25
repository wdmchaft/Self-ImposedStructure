//
//  SummaryEventTaskData.m
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryTaskData.h"


@implementation SummaryTaskData


- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [super.data count]);
    NSDictionary *params  = [super.data objectAtIndex:row];
	NSCell *cell = [tableColumn headerCell];
	NSString *colName = (NSString*) [cell stringValue];
	if ([colName isEqualToString:@"COL2"]){
		NSString *val;
		val = (NSString*)[params objectForKey:@"name"];
		theValue = val;
	} else {
		theValue = [NSNumber numberWithInt: 0];
	}
    return theValue;
}


@end
