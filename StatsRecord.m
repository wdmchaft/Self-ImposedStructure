//
//  StatsRecord.m
//  WorkPlayAway
//
//  Created by Charles on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatsRecord.h"


@implementation StatsRecord
@synthesize activity;
@synthesize task;
@synthesize source;
@synthesize hour;
@synthesize today;
@synthesize week;
@synthesize month;
- (id) initWithName: (NSString*) name
{
	if (self)
	{
		self.activity = name.copy;
	}
	return self;
}

-(BOOL) isEqual:(id)object
{
	if ([self class] != [object class])
		return NO;
	StatsRecord *sr = (StatsRecord*) object;
	if (![activity isEqualToString:sr.activity])
		return NO;
	if (![source isEqualToString:sr.source])
		return NO;
	if (![task isEqualToString:sr.task]) 
		return NO;
	return YES;
}
- (NSString*) key
{
	return [NSString stringWithFormat:@"%@%@%@", activity, task, source];
}

-(id) copyWithZone: (NSZone *) zone
{
	StatsRecord *copy = [[[self class] allocWithZone: zone] init];
	
    [copy setActivity:[self activity]];
    [copy setTask:[self task]];
    [copy setSource:[self source]];	
	[copy setHour:[self hour]];
	[copy setToday:[self today]];
	[copy setMonth:[self month]];
	[copy setWeek:[self week]];
    return copy;
}
@end
