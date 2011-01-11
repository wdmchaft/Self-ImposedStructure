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
	if (![sr.activity isEqualToString:activity])
		return NO;
	if (![source isEqualToString:sr.source])
		return NO;
	if (![task isEqualToString:sr.task]) 
		return NO;
	return YES;
}
@end
