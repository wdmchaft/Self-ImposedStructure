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
@synthesize tlHandler;
@synthesize token;
@dynamic context;

- (void) timelineRequest
{
	
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									token, @"auth_token",
									@"rtm.timelines.create", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	tlHandler = (TimelineHandler*)[[TimelineHandler alloc]initWithHandler:self]; 
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: tlHandler];
	[rr release];
	
}

-(void) timelineDone
{
	
	if (![tlHandler timeLine]){
		
		//[BaseInstance sendErrorToHandler:context.handler 
//								   error:@"No time line received" 
//								  module:[context description]]; 
		NSLog(@"oops -- bad");
	}
	else 
	{
		[self sendComplete];
	}
}

- (void) sendComplete
{

	RequestREST *rr = [[RequestREST alloc]init];

	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									token, @"auth_token",
									@"rtm.tasks.complete", @"method",
									[dictionary objectForKey:@"task_id"], @"task_id",
									[dictionary objectForKey:@"taskseries_id"], @"taskseries_id",
									[dictionary objectForKey:@"list_id"], @"list_id",
									[tlHandler timeLine], @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *handler = [[CompleteRespHandler alloc]initWithHandler:self]; 
	
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: handler];
	[rr release];	
}

- (void) rmDone
{
	if ([callback respondsToSelector:@selector(handleComplete:)]){
		[callback handleComplete:nil];
	}
}

- (void) start 
{
	[self timelineRequest];
}

- (id) initWithDictionary:(NSDictionary*) dict token: tokenStr andDelegate: (id<RTMCallback>) delegate{
	if (self)
	{
		token = tokenStr;
		callback = delegate;
		dictionary = dict;
	}
	return self;
}

- (void) frobDone{}
- (void) listDone{}
- (void) tokenDone{}
- (void) taskRefreshDone{}
- (void) refreshDone{}
- (void) listsDone{}
- (void) handleComplete{}
@end
