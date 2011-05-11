//
//  ActivityComboData.m
//  WorkPlayAway
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "ActivityComboData.h"
#import "TaskList.h"

@implementation ActivityComboData
@synthesize dialog ;

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	id<TaskList> tl = [dialog list];
	return [[tl getTasks] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	id<TaskList> tl = [dialog list];
	NSArray *items = [tl getTasks];	

	NSDictionary *itemAttrs = [items objectAtIndex:index];
	return [itemAttrs objectForKey:@"name"];
}
@end