//
//  SummaryData.m
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SummaryData.h"


@implementation SummaryData
@synthesize data;

- (id) init
{
	if (self)
	{
		data = [NSMutableArray new];
	}
	return self;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [data count];
}

- (void) sort
{
	NSLog(@"sort base class");
}

- (void) clear
{
	[data removeAllObjects];
}

@end
