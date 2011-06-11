//
//  BaseTaskList.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "BaseTaskList.h"
#import "Queues.h"


@implementation BaseTaskList
@synthesize tracked;
@dynamic baseQueue;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic summaryTitle;
@dynamic isWorkRelated;
@dynamic enabled;
@dynamic name;
@dynamic category;
@dynamic params;

-(void) saveDefaults{
	[self saveDefaultValue:[NSNumber numberWithInt:tracked] forKey:TRACKED];
	[super saveDefaults];
}

-(void) clearDefaults{
	[self clearDefaultValue:[NSNumber numberWithInt:tracked] forKey:TRACKED];
	[super clearDefaults];
}

-(void) loadDefaults{
	[super loadDefaults];
	NSNumber *temp = [self loadDefaultForKey:TRACKED];
	tracked = [temp intValue];
}



@end
