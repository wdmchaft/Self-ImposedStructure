//
//  TaskInfo.m
//  WorkPlayAway
//
//  Created by Charles on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskInfo.h"


@implementation TaskInfo
@synthesize name;
@synthesize source;
@synthesize project;


-(BOOL) isEqual:(id)object
{
	if (![[object class] isEqual: [self class]])
		return NO;
	TaskInfo *otherTask = (TaskInfo*) object;
	if (![name isEqualToString: otherTask.name])
		return NO;
	if (![project isEqualToString: otherTask.project])
		return NO;
	if (![source isEqual: otherTask.source])
		return NO;
	return YES;
}

-(id) initWithName: (NSString*) item source: (<Module>) mod  project: (NSString*) proj
{
	if (self)
	{
		name = item.copy;
		project = proj.copy;
		source = mod;
	}
	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"[%@] %@", [source description], name];
}

-(id) copyWithZone: (NSZone *) zone
{
	TaskInfo *copy = [[[self class] allocWithZone: zone] init];
	
    [copy setName:[self name]];
    [copy setProject:[self project]];
    [copy setSource:[self source]];	
    return copy;
}
@end
