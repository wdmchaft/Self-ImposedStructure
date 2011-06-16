//
//  NewTaskHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 4/30/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "NewTaskHandler.h"
#import "RequestREST.h"
#import "TimelineHandler.h"
#import "Secret.h"
#import "CompleteRespHandler.h"

@implementation NewTaskHandler
@synthesize dictionary;

@dynamic context;



- (void) simpleDone
{
	id<Instance> inst = [context module];
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	NSDictionary *modInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							 [dictionary objectForKey:@"module"], @"module",
							 nil];
	[dnc postNotificationName:[inst updateQueue] object:nil userInfo: modInfo];
	[target performSelector:callback withObject:nil];
}

- (void) start 
{
	//[self timelineRequest];
	[context sendAdd:self callback: @selector(simpleDone) params: dictionary];
}



@end
