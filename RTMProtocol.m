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
@synthesize handler;
@synthesize lastError;
@synthesize workRouter;
@synthesize timelineQueue;
//@synthesize parameters;

- (NSMutableDictionary*) router
{
	if (!workRouter){
		workRouter = [NSMutableDictionary new];
	}
	return workRouter;
}

- (NSMutableArray*) tlq
{
	if (!timelineQueue){
		timelineQueue = [NSMutableArray new];
	}
	return timelineQueue;
}

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

- (void) sendDate2: (RouteInfo*) info
{
	NSDictionary *newDict = [info params];
	[self sendWithRoute: info
			   returnTo: self 
			   callback: @selector(handleTask:) 
			 methodName: @"rtm.tasks.setDueDate" 
				 params: newDict 
			optionNames: [NSArray arrayWithObjects:@"due", @"has_due_time", nil]];	
	
}

- (void) sendDate: (NSObject*) target callback: (SEL) cb date: (NSDate *) newDate task: (NSDictionary*) tdc
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	BOOL hasDate = newDate != 0;
	[newDict setObject:[NSNumber numberWithBool:hasDate] forKey:@"has_due_time"];
	if (hasDate){
		NSDateFormatter *inputFormatter = [NSDateFormatter new];
     	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [inputFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];  
		NSString *newDateStr = [inputFormatter stringFromDate:newDate];
		[newDict setObject:newDateStr forKey:@"due"];
		[newDict setObject:newDate forKey:@"due_time"];
	} else {
		[newDict setObject:[NSDate distantFuture] forKey:@"due_time"];
	}


	[self timelineRequest:target callback:cb nextStep: @selector(sendDate2:) params: newDict];
}

- (void) sendName2: (RouteInfo*) info
{
	NSDictionary *newDict = [info params];
	[self sendWithRoute: info 
			   returnTo: self 
			   callback: @selector(handleTask:)
			 methodName: @"rtm.tasks.setName" 
				 params:newDict
			optionNames:[NSArray arrayWithObject:@"name"]];
}

- (void) sendName: (NSObject*) target callback: (SEL) cb name: (NSString *) newName task: (NSDictionary*) tdc
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	[newDict setObject:newName forKey:@"priority"];
	[self timelineRequest:target callback:cb nextStep: @selector(sendName2:) params: newDict];

}

- (void) sendPriority2: (RouteInfo*) info
{
	NSDictionary *newDict = [info params];
	NSArray *optionNames = nil;
	int prio = [[newDict objectForKey:@"priority"] intValue];
	
	// only send priority if it exists (non-zero)
	
	if (prio > 0){
		optionNames = [NSArray arrayWithObject:@"priority"];
	}
	[self sendWithRoute: info 
			   returnTo: self 
			   callback: @selector(handleTask:)
			 methodName: @"rtm.tasks.setPriority" 
				 params:newDict
			optionNames:optionNames];
}

- (void) sendPriority: (NSObject*) target callback: (SEL) cb priority: (int) prio task: (NSDictionary*) tdc
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	[newDict setObject:[NSNumber numberWithInt:prio] forKey:@"priority"];
	[self timelineRequest:target callback:cb nextStep: @selector(sendPriority2:) params: newDict];
	
}

- (void) sendNote2: (RouteInfo*) info
{
	NSMutableDictionary *newDict = [info params];
	NSString *method =  [newDict objectForKey:@"method"];
	NSArray *extra = [NSArray arrayWithObjects:@"note_title", @"note_text", @"note_id", nil];
	if ([method isEqualToString: @"rtm.tasks.notes.delete"])
		extra = [NSArray arrayWithObject:@"note_id"];
	if ([method isEqualToString: @"rtm.tasks.notes.add"])
		extra = [NSArray arrayWithObjects:@"note_title", @"note_text",nil];
	[self sendWithRoute:info 
				  returnTo: self 
				  callback: @selector(handleTask:) 
				methodName: method
					params: newDict
			   optionNames: extra];
	if ([method isEqualToString: @"rtm.tasks.notes.delete"]) {
		[newDict removeObjectForKey:@"note_text"];
	}
}

- (void) sendNote: (NSObject*) target callback: (SEL) cb 
			  newVal: (NSString *) newNote oldVal: (NSString*) oldNote
			 task: (NSDictionary*) tdc
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	if (newNote) {
		[newDict setObject:newNote forKey:@"note_text"];
	} 

	NSString *oldTitle =  [tdc objectForKey:@"note_title"];
	NSString *newTitle = oldTitle ? oldTitle : @"";
	NSString *method = @"rtm.tasks.notes.edit";
	if (!oldNote) {
		method = @"rtm.tasks.notes.add";
	} 
	if (!newNote){
		method = @"rtm.tasks.notes.delete";
	}
	[newDict setObject:method forKey:@"method"];
	[newDict setObject:newTitle forKey:@"note_title"];
	[self timelineRequest:target callback:cb nextStep: @selector(sendNote2:) params: newDict];

}


- (void) sendWithRoute: (RouteInfo*) info
				 returnTo: (NSObject*) target 
				 callback: (SEL) cb 
			   methodName: (NSString*) method 
				   params: (NSDictionary*) tdc
			  optionNames: (NSArray*) names
{
	RequestREST *rr = [[RequestREST alloc]init];
	
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									method, @"method",
									[tdc objectForKey:@"task_id"], @"task_id",
									[tdc objectForKey:@"taskseries_id"], @"taskseries_id",
									[tdc objectForKey:@"list_id"], @"list_id",
									[info timeline], @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	// add optional parameters
	
	for (NSString *optKey in names){
		NSObject *value = [tdc objectForKey:optKey];
		if (value) {
			[params setObject:value forKey:optKey];
		}
	}
	
	CompleteRespHandler *crHandler = (CompleteRespHandler*)
		[[CompleteRespHandler alloc]initWithContext:self
										   delegate: target
										   selector:cb 
											  route:info ]; 
	
	//timelineStr = nil; // we are about to fetch a new time line
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];
	
}


- (void) sendSimple: (NSObject*) target callback: (SEL) cb methodName: (NSString*) method params: (NSDictionary*) tdc 
{
	[self send: target callback: cb methodName: method params: tdc optionNames: nil];	
}

- (void) nextStep: (NSString*) timeline
{
	RouteInfo *info = [[self tlq] lastObject];
	[[self tlq] removeLastObject];
	[info setTimeline: timeline];
	[self performSelector: [info step2] withObject:info];
}

- (void) timelineRequest: (NSObject*) target callback: (SEL) cb nextStep: (SEL) s2 params: (NSDictionary*) dict
{
	[[self tlq] addObject:[[RouteInfo alloc]initWithTarget:target selector:cb step2:s2 params:dict]];
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.timelines.create", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	TimelineHandler *tlHandler = (TimelineHandler*)[[TimelineHandler alloc]initWithContext:self
																				  delegate: self
																				  selector:@selector(nextStep:)]; 
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: tlHandler];
	[rr release];
	
}

- (void) deleteTask: (RouteInfo*) info
{
	NSString *targId = [[info params] objectForKey:@"task_id"];
	for (NSDictionary *task in [self tasksList	])
	{
		NSString *taskId = [task objectForKey:@"task_id"];
		if ([taskId isEqualToString:targId]) {
			[[self tasksDict] removeObjectForKey:[task objectForKey:@"name"]];
			continue;
		}
	}
	tasksList = [NSMutableArray arrayWithArray:[[self tasksDict] allValues]];
}

- (void) updateTask: (RouteInfo*) info
{
	NSDictionary *newTask = [info params];
	NSString *targId = [newTask objectForKey:@"task_id"];
	NSString *newName = [newTask objectForKey:@"name"];	
	for (NSDictionary *task in [self tasksList])
	{
		NSString *taskId = [task objectForKey:@"task_id"];
		if ([taskId isEqualToString:targId]) {
			NSString *oldName = [task objectForKey:@"name"];
			[[self tasksDict] removeObjectForKey:oldName];
			[[self tasksDict] setObject:[info params] forKey:newName];
			continue;
		}
	}
	tasksList = [NSMutableArray arrayWithArray:[[self tasksDict] allValues]];
}

- (void) addTask: (RouteInfo*) info
{
	NSString *name = [[info params] objectForKey:@"name"];
	NSMutableDictionary *newEntry = [NSMutableDictionary dictionaryWithDictionary:[info params]];
	[[self tasksDict] setObject: newEntry forKey:name];
	tasksList = [NSMutableArray arrayWithArray:[[self tasksDict] allValues]];
}

- (void) handleTask: (RouteInfo*) info
{
	NSObject *targ = [info target];
	SEL cb = [info method];
	SEL step2 = [info step2];
	if (step2 == @selector(sendComplete2:) || 
		step2 == @selector(sendMoveTo2:)) {
		[self deleteTask:info];
	}
	if (step2 == @selector(sendAdd2:)){
		NSLog(@"adding task to cache");
		[self addTask:info];
	}
	if (step2 == @selector(sendName2:) ||
		step2 == @selector(sendDate2:) ||
		step2 == @selector(sendPriority2:) ||
		step2 == @selector(sendNote2:)){
		[self updateTask:info];
	}
	[targ performSelector:cb];
}

- (void) sendMoveTo: (NSObject*) target callback: (SEL) cb list: (NSString*) newList params: (NSDictionary*) tdc
{
	NSMutableDictionary *parms = [NSMutableDictionary dictionaryWithDictionary:tdc];
	[parms setObject:newList forKey:@"to_list_id"];
	[self timelineRequest:target callback:cb nextStep:@selector(sendMoveTo2:) params:parms];
}

- (void) sendMoveTo2: (RouteInfo*) info
{
	NSString *timelineStr = [info timeline];
	NSDictionary *tdc = [info params];
	//	selfstructAppDelegate *delegate = (<NSApplicationDelegate>)[NSApplication sharedApplication];
	//	context = [delegate context];
	RequestREST *rr = [[RequestREST alloc]init];
	[[self router] setObject:info forKey:timelineStr];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.moveTo", @"method",
									[tdc objectForKey:@"to_list_id"], @"to_list_id",
									[tdc objectForKey:@"task_id"], @"task_id",
									[tdc objectForKey:@"taskseries_id"], @"taskseries_id",
									listIdStr, @"from_list_id",
									timelineStr, @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", 
									nil];
	
	CompleteRespHandler *crHandler = (CompleteRespHandler*)
		[[CompleteRespHandler alloc]initWithContext:self
										   delegate: self
										   selector:@selector(handleTask:) 
											  route:info] ; 	
	timelineStr = nil; // we are about to fetch a new time line
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];
	
}

- (void) sendComplete2: (RouteInfo*) info;
{
	NSDictionary* dictionary = [info params];
	RequestREST *rr = [[RequestREST alloc]init];
	
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.complete", @"method",
									[dictionary objectForKey:@"task_id"], @"task_id",
									[dictionary objectForKey:@"taskseries_id"], @"taskseries_id",
									[dictionary objectForKey:@"list_id"], @"list_id",
									[info timeline], @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *crHandler = [[CompleteRespHandler alloc]
									  initWithContext:self
									  delegate:self
									  selector:@selector(handleTask:)
									  route:info]; 
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];	
}

- (void) sendComplete: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary;
{
	[self timelineRequest:target callback:cb nextStep:@selector(sendComplete2:) params:dictionary];	
}

- (void) sendAdd2: (RouteInfo*) info
{
	NSDictionary* dictionary = [info params];
	
	RequestREST *rr = [[RequestREST alloc]init];
	
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.add", @"method",
									[dictionary objectForKey:@"name"], @"name",
									@"1", @"parse",
									listIdStr, @"list_id",
									[info timeline], @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *crHandler = [[CompleteRespHandler alloc]initWithContext:self
																		delegate:self
																		selector:@selector(handleTask:)
																		   route:info]; 
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: crHandler];
	[rr release];	
}


- (void) sendAdd: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary
{
	[self timelineRequest:target callback:cb nextStep:@selector(sendAdd2:) params:dictionary];	
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
		[copy setListIdStr:[self listIdStr]];
		[copy setListNameStr:[self listNameStr]];
	}
	return copy;
}


@end

@implementation RouteInfo

@synthesize target;
@synthesize method;
@synthesize timeline;
@synthesize step2;
@synthesize params;
@synthesize ok;
						
- (id) initWithTarget: (NSObject*) obj selector: (SEL) sel step2: (SEL) next params: (NSDictionary*) dict
{
	if ( self = [super init]) {
		target = obj;
		method = sel;
		step2 = next;
		params = dict;
	}
	return self;
}
@end

