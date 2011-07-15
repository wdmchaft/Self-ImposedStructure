//
//  ActivityComboData.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "ActivityComboData.h"
#import "TaskList.h"

@implementation ActivityComboData
@synthesize  list;
- (void) awakeFromNib
{
	NSLog(@"here");
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [[list getTasks] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	NSArray *items = [list getTasks];	

	NSDictionary *itemAttrs = [items objectAtIndex:index];
	return [itemAttrs objectForKey:@"name"];
}
@end
