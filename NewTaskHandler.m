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
		[context sendAdd:self callback: @selector(rmDone) params: dictionary];
	}
}


- (void) rmDone
{
	[target performSelector:callback withObject:nil];
}

- (void) start 
{
	[self timelineRequest];
}



@end
