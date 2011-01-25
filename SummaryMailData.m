//
//  SummaryMailData.m
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryMailData.h"


@implementation SummaryMailData

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [super.data count]);
    NSDictionary *params  = [super.data objectAtIndex:row];
	theValue = [params objectForKey:@"summary"];

    return theValue;
}

@end
