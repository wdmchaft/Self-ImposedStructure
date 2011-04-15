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
	if (name == nil && otherTask.name)
		return NO;
	if (otherTask.name == nil && name)
		return NO;
	if (name && otherTask.name && ![name isEqualToString: otherTask.name])
		return NO;
	if (project == nil && otherTask.project)
		return NO;
	if (otherTask.project == nil && project)
		return NO;
	if (project && otherTask.project && ![project isEqualToString: otherTask.project])
		return NO;
	if (source == nil && otherTask.source == nil)
		return YES;
	if (![((NSObject*)source) isEqual: ((NSObject*)otherTask.source)])
		return NO;
	return YES;
}

-(id) initWithName: (NSString*) item source: (id<TaskList>) mod  project: (NSString*) proj
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
	if (description)
		return description;
	return name;
}

- (void) setDescription: (NSString *) newDesc
{
	description = [newDesc copy];
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
