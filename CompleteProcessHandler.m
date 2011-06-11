//
//  CompleteProcessHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/25/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "CompleteProcessHandler.h"
#import "RequestREST.h"
#import "TimelineHandler.h"
#import "Secret.h"
#import "CompleteRespHandler.h"

@implementation CompleteProcessHandler
@synthesize dictionary;

@dynamic context;

- (void) timelineRequest
{
	[context sendComplete:self callback:@selector(simpleDone)  params:dictionary];
}

//
//-(void) timelineDone: (RouteInfo*) info
//{
//	
//	if (![context timelineStr]){
//		
//		//[BaseInstance sendErrorToHandler:context.handler 
////								   error:@"No time line received" 
////								  module:[context description]]; 
//		//NSLog(@"oops -- bad");
//	}
//	else 
//	{
//		[context sendComplete:self callback: @selector(simpleDone) params: dictionary];
//	}
//}

- (void) simpleDone
{
	id<Instance> inst = [context module];
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	NSDictionary *taskInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [dictionary objectForKey:@"name"], @"task",
							  [dictionary objectForKey:@"project"], @"project",
							  [dictionary objectForKey:@"project"], @"source",
							  nil];
	[dnc postNotificationName:[inst completeQueue] object:nil userInfo: taskInfo];
	NSDictionary *modInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							 [dictionary objectForKey:@"project"], @"module",
							 nil];
	[dnc postNotificationName:[inst updateQueue] object:nil userInfo: modInfo];
	[target performSelector:callback withObject:nil];
	
}

- (void) start 
{
	[self timelineRequest];
}


@end
