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
	[context timelineRequest:self callback:@selector(timelineDone)];
}


-(void) timelineDone
{
	
	if (![context timelineStr]){
		
		//[BaseInstance sendErrorToHandler:context.handler 
//								   error:@"No time line received" 
//								  module:[context description]]; 
		//NSLog(@"oops -- bad");
	}
	else 
	{
		[context sendComplete:self callback: @selector(simpleDone) params: dictionary];
	}
}


- (void) simpleDone
{
	[target performSelector:callback withObject:nil];
}

- (void) start 
{
	[self timelineRequest];
}


@end
