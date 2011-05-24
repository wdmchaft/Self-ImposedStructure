//
//  RTMProtocol.m
//  Self-Imposed Structure
//
//  Created by Charles on 4/28/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//
#define EMAIL @"Email"
#define PASSWORD @"Password"
#define REFRESH @"Refresh"
#define LISTNAME @"ListName"
#define TOKEN  @"Token"
#define LISTID @"ListId"
#define TASKLIST @"taskList"
#define ISWORK @"isWork"
#define LOOKAHEAD @"lookAhead"
#import "RTMProtocol.h"

#import "Secret.h"
#import "RTMModule.h"
#import "WPAAlert.h"
#import "RequestREST.h"
#import "ListHandler.h"
#import "ListsHandler.h"
#import "TokenHandler.h"
#import "RefreshHandler.h"
#import "RefreshListHandler.h"
#import "TaskDialogController.h"
#import "Utility.h"
#import "CompleteProcessHandler.h"
#import "CompleteRespHandler.h"

@implementation RTMProtocol

@synthesize module;
@synthesize tokenStr; 
@synthesize userStr; 
@synthesize passwordStr; 
@synthesize frobStr; 
@synthesize listNameStr;
@synthesize idMapping;
@synthesize tasksDict;
@synthesize tasksList;

@synthesize listIdStr;
@synthesize timelineStr;
@synthesize handler;
@synthesize lastError;
//@synthesize parameters;



-(void) runListReqWithHandler: (<ResponseHandler>)respHndler
{
	RequestREST *rr = [[RequestREST alloc]init];
	
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.getList", @"method",
									listIdStr,@"list_id",
									@"xml", @"format",
									@"status:incomplete:", @"filter",
									APIKEY, @"api_key", 
                                    nil];
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET 
										 andParams:params]
				andHandler: respHndler];
	[rr release];
	
}
-(void) updateList: (NSObject*) target callback: (SEL) cb
{
	RefreshListHandler *refHandler = [[[RefreshListHandler alloc]initWithContext:self
																		delegate: target
																		selector:cb ] autorelease];
	[self runListReqWithHandler:refHandler];
}


-(void) startRefresh: (NSObject*) target callback: (SEL) cb
{
	RefreshHandler *refHandler = [[[RefreshHandler alloc]initWithContext:self
																delegate: target
																selector:cb ] autorelease];
	[self runListReqWithHandler:refHandler];
}

- (void) handleWarningAlarm: (NSTimer*) theTimer
{
	WPAAlert *alert = (WPAAlert*)[theTimer userInfo];
	[handler handleAlert:alert];
}

//- (void) refresh: (id<AlertHandler>) alertHandler isSummary: (BOOL) summary
//{
//	self.handler = alertHandler;
//	[self startRefresh];
//}

- (void) getToken: (NSObject*) target callback: (SEL) cb
{
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									frobStr, @"frob",
									@"rtm.auth.getToken", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	TokenHandler *tokHandler = (TokenHandler*)[[[TokenHandler alloc]initWithContext:self
																		  delegate: target
																		  selector:cb ] autorelease]; 
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: tokHandler];
	[rr release];		
}

- (void) getFrob: (NSObject*) target callback: (SEL) cb
{
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									@"rtm.auth.getFrob", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	FrobHandler *frobHandler = (FrobHandler*)[[[FrobHandler alloc]initWithContext:self
																		delegate: target
																		selector:cb ] autorelease];
	//NSURLConnection *obj = [rr sendRequest:@"rtm.auth.getFrob" 
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret: SECRET  
										 andParams:params]
				andHandler: frobHandler];
	[rr release];		
}

- (NSString*) getAuthURL
{
	RequestREST *rr = [[RequestREST alloc]init];
	NSString *urlStr = [rr createURLWithFamily: @"auth" 
								   usingSecret: SECRET
									 andParams:
						[NSDictionary dictionaryWithObjectsAndKeys:
						 APIKEY, @"api_key",
						 @"delete", @"perms",
						 frobStr, @"frob", 
						 nil]];
	return urlStr;
}


- (void) getLists: (NSObject*) target callback: (SEL) cb
{
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.lists.getList", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	ListsHandler *listsHandler = (ListsHandler*)[[[ListsHandler alloc]initWithContext:self
																			delegate: target
																			selector:cb ] autorelease]; 
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET 
										 andParams:params]
				andHandler: listsHandler];
	[rr release];
}


- (void) sendRm: (NSObject*) target callback: (SEL) cb methodName: (NSString*) method params: (NSDictionary*) tdc 
{
	//	selfstructAppDelegate *delegate = (<NSApplicationDelegate>)[NSApplication sharedApplication];
	//	context = [delegate context];
	RequestREST *rr = [[RequestREST alloc]init];
	//NSLog(@"auth %@\n task %@\n series %@\n list %@\n api %@",[tdc objectForKey:@"auth_token"],
	//	  [tdc objectForKey:@"task_id"],
	//	  [tdc objectForKey:@"taskseries_id"], 
	//	  [tdc objectForKey:@"list_id"],
	//	  [tdc objectForKey:@"api_key"],nil);
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									method, @"method",
									[tdc objectForKey:@"task_id"], @"task_id",
									[tdc objectForKey:@"taskseries_id"], @"taskseries_id",
									[tdc objectForKey:@"list_id"], @"list_id",
									timelineStr, @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *crHandler = (CompleteRespHandler*)[[[CompleteRespHandler alloc]initWithContext:self
																							  delegate: target
																							  selector:cb ] autorelease]; 
	
	timelineStr = nil; // we are about to fetch a new time line
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];
	
}

- (void) timelineRequest: (NSObject*) target callback: (SEL) cb
{
	
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.timelines.create", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	TimelineHandler *tlHandler = (TimelineHandler*)[[[TimelineHandler alloc]initWithContext:self
																				  delegate: target
																				  selector:cb ] autorelease]; 
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: tlHandler];
	[rr release];
	
}

- (void) sendMoveTo: (NSObject*) target callback: (SEL) cb list: (NSString*) newList params: (NSDictionary*) tdc
{
	//	selfstructAppDelegate *delegate = (<NSApplicationDelegate>)[NSApplication sharedApplication];
	//	context = [delegate context];
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.moveTo", @"method",
									newList,@"to_list_id",
									[tdc objectForKey:@"task_id"], @"task_id",
									[tdc objectForKey:@"taskseries_id"], @"taskseries_id",
									[tdc objectForKey:@"list_id"], @"from_list_id",
									timelineStr, @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *crHandler = (CompleteRespHandler*)[[[CompleteRespHandler alloc]initWithContext:self
																							  delegate: target
																							  selector:cb ] autorelease]; 	
	timelineStr = nil; // we are about to fetch a new time line
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];
	
}

- (void) sendComplete: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary;
{
	RequestREST *rr = [[RequestREST alloc]init];
	
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.complete", @"method",
									[dictionary objectForKey:@"task_id"], @"task_id",
									[dictionary objectForKey:@"taskseries_id"], @"taskseries_id",
									[dictionary objectForKey:@"list_id"], @"list_id",
									timelineStr, @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *crHandler = [[[CompleteRespHandler alloc]initWithContext:self
																		delegate: target
																		selector:cb ] autorelease]; 
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];	
}

- (void) sendAdd: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary
{
	
	RequestREST *rr = [[RequestREST alloc]init];
	
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.add", @"method",
									[dictionary objectForKey:@"name"], @"name",
									@"1", @"parse",
									listIdStr, @"list_id",
									timelineStr, @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *crHandler = [[CompleteRespHandler alloc]initWithContext:self
																	  delegate:target
																	  selector:cb]; 
	
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];	
}



// if there is an error then put out an error message saying results may be out of date 
// but return the last copy of the list
- (void) handleRTMError:(NSDictionary*) errInfo
{
    NSString *msg = [errInfo objectForKey:@"msg"];
    NSLog(@"Error communicating with Remember The Milk [%@]", msg);
    [BaseInstance sendErrorToHandler:handler
                               error:@"Could not contact Remember the Milk at this time. Using last known task list."
                              module:module.name];
    [self listDone]; // handle this
}

-(id)copyWithZone: (NSZone*)zone {
    RTMProtocol *copy =  [[[self class] allocWithZone:zone] init];
	if (copy) {
		[copy setTasksDict:[self tasksDict]];
		[copy setTasksList:[self tasksList]];
		[copy setPasswordStr:[self passwordStr]];	
		[copy setTokenStr:[self tokenStr]];
		[copy setUserStr:[self userStr]];
		[copy setTimelineStr:[self timelineStr]];
		[copy setListIdStr:[self listIdStr]];
		[copy setListNameStr:[self listNameStr]];
	}
	return copy;
}


@end
