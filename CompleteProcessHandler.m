//
//  CompleteProcessHandler.m
//  WorkPlayAway
//
//  Created by Charles on 1/25/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "CompleteProcessHandler.h"
#import "RequestREST.h"
#import "TimelineHandler.h"
#import "Secret.h"
#import "CompleteRespHandler.h"

@implementation CompleteProcessHandler
@synthesize context;
@synthesize tlHandler;
@synthesize token;

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

- (void) sendComplete: (NSString*) method
{
	//	RTGTestAppDelegate *delegate = (<NSApplicationDelegate>)[NSApplication sharedApplication];
	//	context = [delegate context];
	RequestREST *rr = [[RequestREST alloc]init];

	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									token, @"auth_token",
									method, @"method",
									[context objectForKey:@"task_id"], @"task_id",
									[context objectForKey:@"taskseries_id"], @"taskseries_id",
									[context objectForKey:@"list_id"], @"list_id",
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
	if ([callback respondsToSelector:@selector(completeDone)]){
		[callback completeDone];
	}
}

- (void) start 
{
	[self timelineRequest];
}

- (id) initWithContext:(NSDictionary*) ctx token: tokenStr andDelegate: (NSObject*) delegate{
	if (self)
	{
		token = tokenStr;
		callback = delegate;
		context = ctx;
	}
	return self;
}

@end