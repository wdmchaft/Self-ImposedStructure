//
//  GTProtocol.m
//  Self-Imposed Structure
//
//  Created by Charles on 4/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
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
#import "GTProtocol.h"
#import "GTMOAuth2WindowController.h"

#import "Secret.h"
#import "WPAAlert.h"
#import "Utility.h"
#import "GTMHTTPFetcher.h"
#import "GTMHTTPFetcherLogging.h" 
#import "SBJSON.h"

@implementation SelWrapper

@synthesize selector;

@end

@implementation GTProtocol

@synthesize module;
@synthesize listNameStr;
@synthesize idMapping;
@synthesize tasksDict;
@synthesize tasksList;
@synthesize auth;
@synthesize target;
@synthesize callback;
@synthesize listIdStr;
@synthesize listLinkStr;
@synthesize timelineStr;
@synthesize handler;
@synthesize lastError;
@synthesize step2Handler;
@synthesize json;
@synthesize errorCallback;
@synthesize saveTask;
@synthesize dateFormatter;
@synthesize moveToListId;

//@synthesize parameters;

- (id) init
{
	self = [super init];
	if (self)
	{
		json = [SBJSON new];
		[GTMHTTPFetcher setLoggingEnabled:YES];
		dateFormatter = [NSDateFormatter new];
		[dateFormatter  setDateFormat:@"yyyy'-'MM'-'dd'T'hh':'mm':'ss'.'SSS'Z'" ];
	}
	return self;
}

- (void) handleError: (NSError*) error
{
	if ([target conformsToProtocol:@protocol(GTProtocolErrorDelegate)]){
		SelWrapper *wrap = [SelWrapper new];
		[wrap setSelector:callback];
		id<GTProtocolErrorDelegate> delegate = (<GTProtocolErrorDelegate>) target;
		//	- (void) gtProtocol: (GTProtocol*) callEndingAt: (SelWrapper*) selObj gotError: (NSError*) error;
		[delegate gtProtocol:self callEndingAt: wrap gotError: error];
	}
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
- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)retAuth
                   error:(NSError *)error {
	
	if (error != nil) {
		// Authentication failed (perhaps the user denied access, or closed the
		// window before granting access)
		NSString *errorStr = [error localizedDescription];
		
		NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
		if ([responseData length] > 0) {
			// Show the body of the server's authentication failure response
			errorStr = [[[NSString alloc] initWithData:responseData
											  encoding:NSUTF8StringEncoding] autorelease];
		} else {
			NSString *str = [[error userInfo] objectForKey:kGTMOAuth2ErrorMessageKey];
			if ([str length] > 0) {
				errorStr = str;
			}
		}
		NSAlert *alert = [NSAlert alertWithMessageText:@"Not Authorized" 
										 defaultButton:nil alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:errorStr];
		[alert runModal];	
		
		[self setAuth:nil];
	} else {
		
		// save the authentication object
		[self setAuth:retAuth];
		
	}
	[target performSelector:callback];
}

- (void) getTokenInWindow: (NSWindow*) win handler:(NSObject*) retHandler returnTo: (SEL) cb
{
	target = retHandler;
	callback = cb;
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	GTMOAuth2WindowController *authCtrl = [[GTMOAuth2WindowController alloc] initWithScope:SCOPE
																				  clientID:CLIENT_ID
																			  clientSecret:API_SECRET
																		  keychainItemName:KEYCHAIN_ID
																			resourceBundle:myBundle];
	
	[authCtrl signInSheetModalForWindow:win
							   delegate:self
					   finishedSelector:@selector(windowController:finishedWithAuth:error:)];		
}

- (void) listsDone:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	if (error){
		[self handleError:error];
	}
	else {
		NSString *dataStr = [[[NSString alloc] initWithData:data
												   encoding:NSUTF8StringEncoding] autorelease];
		NSError *err = nil;
		NSDictionary *dict = [json objectWithString:dataStr error:&err];
		NSArray *items = [dict objectForKey:@"items"];
		idMapping = [NSMutableDictionary new];
		for (NSDictionary *item in items){
			NSDictionary *newItem = [NSDictionary dictionaryWithDictionary:item];
			
			NSString *listTitle = [[newItem objectForKey:@"title"] copy];
			[idMapping setObject:newItem forKey:listTitle];
		}	
	}
	[target performSelector:callback];
}

- (void) listDone:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	if (error){
		[self handleError:error];
		return;
	}
	NSString *dataStr = [[[NSString alloc] initWithData:data
											   encoding:NSUTF8StringEncoding] autorelease];
	NSError *err = nil;
	NSDictionary *dict = [json objectWithString:dataStr error:&err];
	if (err){
		[self handleError:err];
		return;
	}
	
	// the only notable thing here is that google tasks lists always have one
	// empty item (where title = "") that we want to ignore.
	
	NSArray *items = [dict objectForKey:@"items"];
	tasksList = [NSMutableArray arrayWithCapacity:[items count]];
	for (NSDictionary *item in items){
		NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
		NSString *titleStr = [newItem objectForKey:@"title"];
		if ([titleStr length] > 0) {
			[newItem setObject:titleStr forKey:@"name"];
			NSString *dueDateStr = [newItem objectForKey:@"due"];
			if (dueDateStr){
				NSDate *dueDate = [dateFormatter dateFromString:dueDateStr];
				[newItem setObject:dueDate forKey:@"due_time"];
			}
			[tasksList addObject:newItem];
		}
		
	}	
	[target performSelector:callback];
}

- (void) updateList:(NSObject*) caller returnTo:(SEL) cb
{
	[self getList:caller returnTo:cb];
}

- (void) returnToSender:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSString *res = [[NSString alloc] initWithData:data
										  encoding:NSUTF8StringEncoding];
	if (error){
		[self handleError:error];
		return;
	}
	NSError *err = nil;
	NSDictionary *dict = [json objectWithString:res error:&err];
	NSLog(@"%@",dict);
	[target performSelector:callback];
}

- (NSString*) formatTimeStamp:(NSDate*) date
{
	NSString *str = [dateFormatter stringFromDate:date];
	return str;
}
- (NSDictionary*) filterDictionary:(NSDictionary*) dict includeKeys:(NSArray*) keys
{
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
	for (id key in keys){
		if ([dict objectForKey:key]){
			[temp setObject:[dict objectForKey:key] forKey:key];
		}
	}
	return temp;

}
- (NSDictionary*) scrubTask: (NSDictionary*) task isAdd: (BOOL) doingAdd
{
	if (doingAdd){
		return [self filterDictionary: task includeKeys:[NSArray arrayWithObjects:
								 @"title", @"notes", @"due",
								 @"status", @"completed",nil]];
	}
	return [self filterDictionary: task includeKeys:[NSArray arrayWithObjects:
							 @"title", @"notes", @"due", @"status", @"completed",
							 @"selfLink", @"deleted", @"etag", @"parent", @"hidden",
							 @"kind", @"id", @"position", @"updated", nil]];
}

//- (NSDictionary*) scrubTask: (NSDictionary*) task isAdd: (BOOL) doingAdd
//{
//	NSMutableDictionary *newTask = [NSMutableDictionary dictionaryWithCapacity:5];
//	if ([task objectForKey:@"title"])
//		[newTask setObject:[task objectForKey:@"title"] forKey:@"title"];
//	if ([task objectForKey:@"notes"])
//		[newTask setObject:[task objectForKey:@"notes"] forKey:@"notes"];
//	if ([task objectForKey:@"due"])
//		[newTask setObject:[task objectForKey:@"due"] forKey:@"due"];
//	if ([task objectForKey:@"status"])
//		[newTask setObject:[task objectForKey:@"status"] forKey:@"status"];
//	if ([task objectForKey:@"completed"])
//		[newTask setObject:[task objectForKey:@"completed"] forKey:@"completed"];
//	if (doingAdd)
//		return newTask;
//	
//	// allow these to pass through for updates / deletes
//	if ([task objectForKey:@"selfLink"])
//		[newTask setObject:[task objectForKey:@"selfLink"] forKey:@"selfLink"];
//	if ([task objectForKey:@"deleted"])
//		[newTask setObject:[task objectForKey:@"deleted"] forKey:@"deleted"];
//	if ([task objectForKey:@"etag"])
//		[newTask setObject:[task objectForKey:@"etag"] forKey:@"etag"];
//	if ([task objectForKey:@"parent"])
//		[newTask setObject:[task objectForKey:@"parent"] forKey:@"parent"];
//	if ([task objectForKey:@"hidden"])
//		[newTask setObject:[task objectForKey:@"hidden"] forKey:@"hidden"];
//	if ([task objectForKey:@"kind"])
//		[newTask setObject:[task objectForKey:@"kind"] forKey:@"kind"];	
//	if ([task objectForKey:@"id"])
//		[newTask setObject:[task objectForKey:@"id"] forKey:@"id"];
//	if ([task objectForKey:@"position"])
//		[newTask setObject:[task objectForKey:@"position"] forKey:@"position"];
//	if ([task objectForKey:@"updated"])
//		[newTask setObject:[task objectForKey:@"updated"] forKey:@"updated"];
//	return newTask;
//}

- (void) finishComplete:(NSDictionary*) task 
{
	NSMutableDictionary *newTask = [NSMutableDictionary dictionaryWithDictionary:task];
	//	[newTask setObject:[self formatTimeStamp:[NSDate date]]forKey:@"completed"];
	[newTask setObject:@"completed" forKey:@"status"];
	NSError *err = nil;
	NSString *payload = [json stringWithObject:[self scrubTask:newTask isAdd:YES] error:&err];
	NSLog(@"payload = [%@]", payload);
	if (err){
		[self handleError:err];
		return;
	}
	NSString *newURLStr = [[task objectForKey:@"selfLink"] stringByAppendingFormat:@"?key=%@",API_SECRET ];
	NSLog(@"url: %@",newURLStr);
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:[NSURL URLWithString:newURLStr]];
	[fetcher setAuthorizer:auth];
	[[fetcher mutableRequest] setHTTPMethod:@"PUT"];
	[[fetcher mutableRequest] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[fetcher setPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(returnToSender:finishedWithData:error:)];
}

- (void) finishUpdate:(NSDictionary*) task 
{
	NSMutableDictionary *newTask = [NSMutableDictionary dictionaryWithDictionary:task];
	//	[newTask setObject:[self formatTimeStamp:[NSDate date]]forKey:@"completed"];
	NSArray *keys = [saveTask allKeys];
	for (NSString *key in keys){
		if ([key isEqualToString:@"due"] && [[saveTask objectForKey:@"due"] isEqualToString: @"nil"]){
			if ([newTask objectForKey:@"due"]){
				[newTask removeObjectForKey:@"due"];
			}
		}
		else {
			[newTask setObject:[saveTask objectForKey:key] forKey:key];
		}
		
	}
	
	NSError *err = nil;
	NSString *payload = [json stringWithObject:newTask error:&err];
	NSLog(@"payload = [%@]", payload);
	if (err){
		[self handleError:err];
		return;
	}
	NSString *newURLStr = [[task objectForKey:@"selfLink"] stringByAppendingFormat:@"?key=%@",API_SECRET ];
	NSLog(@"url: %@",newURLStr);
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:[NSURL URLWithString:newURLStr]];
	[fetcher setAuthorizer:auth];
	[[fetcher mutableRequest] setHTTPMethod:@"PUT"];
	[[fetcher mutableRequest] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[fetcher setPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(returnToSender:finishedWithData:error:)];
}

- (void) gotEtag:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	if (error){
		[self handleError:error];
	}
	NSString *res = [[NSString alloc] initWithData:data
										  encoding:NSUTF8StringEncoding];
	NSError *err = nil;
	NSDictionary *origTask = [json objectWithString:res error:&err];
	if (err){
		[self handleError:err];
	}
	[self performSelector:step2Handler withObject:origTask];
}



- (void) authDone:(GTMOAuth2Authentication *)retAuth
		  request:(NSMutableURLRequest *)request
finishedWithError:(NSError *)error
{
	if (error){
		[self handleError:error];
	}
	[self setAuth:retAuth];
}

- (void) getAuth
{
	
	NSString *urlStr = @"https://www.googleapis.com/tasks/v1/users/@me/lists";
	
	NSURL *url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[auth authorizeRequest:request 
				  delegate:self
		 didFinishSelector:@selector(authDone:request:finishedWithError:)];
}

- (void) getList:(NSObject*) caller returnTo:(SEL) cb
{
	callback = cb;
	target = caller;
	NSString *urlStr = [NSString stringWithFormat:@"%@%@%@",
						@"https://www.googleapis.com/tasks/v1/lists/", 
						listIdStr,
						@"/tasks"];
	urlStr = [urlStr stringByAppendingFormat:@"?showCompleted=false"];
	//urlStr = [urlStr stringByAppendingFormat:@"&dueMax=%@", dueMax];
	NSURL *url = [NSURL URLWithString:urlStr];
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:url];
	[fetcher  setAuthorizer:auth];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(listDone:finishedWithData:error:)];
}

- (void) getLists:(NSObject*) caller returnTo:(SEL) cb
{
	callback = cb;
	target = caller;
	NSString *urlStr = @"https://www.googleapis.com/tasks/v1/users/@me/lists";
	NSURL *url = [NSURL URLWithString:urlStr];
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:url];
	[fetcher  setAuthorizer:auth];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(listsDone:finishedWithData:error:)];
}

- (void) sendEtag: (NSObject*) caller returnTo: (SEL) cb params:(NSDictionary*) task step2Handler: (SEL) s2Handler
{
	callback = cb;
	step2Handler = s2Handler;
	target = caller;
	NSString *urlStr = [task objectForKey:@"selfLink"];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:urlReq];
	[fetcher  setAuthorizer:auth];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(gotEtag:finishedWithData:error:)];	
}

- (void) sendComplete: (NSObject*) caller returnTo: (SEL) cb params:(NSDictionary*) task
{
	[self sendEtag:caller returnTo:cb params: task step2Handler: @selector(finishComplete:)];	
}

- (void) finishDelete:(NSDictionary*) task 
{
	
	NSError *err = nil;
	NSString *payload = [json stringWithObject:task error:&err];
	if (err){
		[self handleError:err];
	} else {
		NSLog(@"payload = [%@]", payload);
		NSString *newURLStr = [[task objectForKey:@"selfLink"] stringByAppendingFormat:@"?key=%@",API_SECRET ];
		NSLog(@"url: %@",newURLStr);
		GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:[NSURL URLWithString:newURLStr]];
		[fetcher setAuthorizer:auth];
		[[fetcher mutableRequest] setHTTPMethod:@"DELETE"];
		[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(returnToSender:finishedWithData:error:)];
	}
}

- (void) sendDelete: (NSObject*) caller returnTo: (SEL) cb params: (NSDictionary*) task 
{
	target = caller;
	callback = cb;
	[self finishDelete: [self scrubTask:task isAdd:NO]];	
}

- (void) sendUpdate: (NSObject*) caller returnTo: (SEL) cb params: (NSMutableDictionary*) task 
{
	NSMutableDictionary *newTask = [NSMutableDictionary dictionaryWithDictionary:[self scrubTask:task isAdd:NO]];
	
	saveTask = task;
	[self sendEtag:caller returnTo:cb params: newTask step2Handler: @selector(finishUpdate:)];	
}

- (void) sendMoveCreate
{
	NSError *err = nil;
	
	NSString *payload = [json stringWithObject:[self scrubTask:saveTask isAdd:YES] error:&err];
	if (err){
		[self handleError:err];
	} else {
		NSLog(@"payload = [%@]", payload);
		NSString *newURLStr = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/tasks?pp=1&key=%@",moveToListId, API_SECRET ];
		NSLog(@"url: %@",newURLStr);
		GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:[NSURL URLWithString:newURLStr]];
		[fetcher setAuthorizer:auth];
		[[fetcher mutableRequest] setHTTPMethod:@"POST"];
		[[fetcher mutableRequest] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[fetcher setPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
		[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(returnToSender:finishedWithData:error:)];
	}
	
}

- (void) finishMoveDelete:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	if (error){
		[self handleError:error];
	}
	else {
	NSError *err = nil;
	
		NSString *payload = [json stringWithObject:[self scrubTask:saveTask isAdd:YES] error:&err];
		if (err){
			[self handleError:err];
			return;
		}
	NSLog(@"payload = [%@]", payload);
	NSString *newURLStr = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/tasks?pp=1&key=%@",moveToListId, API_SECRET ];
	NSLog(@"url: %@",newURLStr);
	fetcher = [GTMHTTPFetcher fetcherWithURL:[NSURL URLWithString:newURLStr]];
	[fetcher setAuthorizer:auth];
	//	[fetcher setMutableRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString: newURLStr]]];
	[[fetcher mutableRequest] setHTTPMethod:@"POST"];
	[[fetcher mutableRequest] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[fetcher setPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(returnToSender:finishedWithData:error:)];
	//[self sendMoveCreate];
}
}

- (void) sendMoveTo: (NSObject*) caller returnTo: (SEL) cb list: (NSDictionary*) listData params: (NSMutableDictionary*) task
{
	moveToListId = [listData objectForKey:@"id"];
	
	saveTask = task;
	NSString *newURLStr = [[task objectForKey:@"selfLink"] stringByAppendingFormat:@"?key=%@",API_SECRET ];
	NSLog(@"url: %@",newURLStr);
	GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:[NSURL URLWithString:newURLStr]];
	[fetcher setAuthorizer:auth];
	[[fetcher mutableRequest] setHTTPMethod:@"DELETE"];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(finishMoveDelete:finishedWithData:error:)];}


- (void) sendAdd: (NSObject*) caller returnTo: (SEL) cb params: (NSDictionary*) newTask listId: (NSString*) idStr
{
	[self setTarget:caller];
	[self setCallback:cb];
	NSError *err = nil;
	NSString *payload = [json stringWithObject:[self scrubTask:newTask isAdd:YES] error:&err];
	if (err){
		[self handleError:err];
	}
	else {
		NSLog(@"payload = [%@]", payload);
		NSString *newURLStr = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/tasks?pp=1&key=%@",idStr, API_SECRET ];
		NSLog(@"url: %@",newURLStr);
		GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:[NSURL URLWithString:newURLStr]];
		[fetcher setAuthorizer:auth];
		[[fetcher mutableRequest] setHTTPMethod:@"POST"];
		[[fetcher mutableRequest] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[fetcher setPostData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
		[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(returnToSender:finishedWithData:error:)];
	}
}

- (void) sendAdd: (NSObject*) caller returnTo: (SEL) cb params: (NSDictionary*) newTask list: (NSDictionary*) listData
{
	NSString *idStr = [listData objectForKey:@"id"];
	[self sendAdd:caller returnTo:cb params:newTask listId: idStr];
}

- (void) sendAdd: (NSObject*) caller returnTo: (SEL) cb params: (NSDictionary*) newTask
{
	[self sendAdd:caller returnTo:cb params:newTask listId: listIdStr];
}

-(id)copyWithZone: (NSZone*)zone {
    GTProtocol *copy =  [[[self class] allocWithZone:zone] init];
	if (copy) {
		[copy setTasksDict:[self tasksDict]];
		[copy setTasksList:[self tasksList]];
		[copy setTimelineStr:[self timelineStr]];
		[copy setListIdStr:[self listIdStr]];
		[copy setListNameStr:[self listNameStr]];
		[copy loadAuth:[self authStr]];
	}
	return copy;
}

- (void) doSignInOnWindow:(NSWindow*) window
{
	// Display the autentication sheet
	GTMOAuth2WindowController *windowController;
	windowController = [[[GTMOAuth2WindowController alloc] initWithScope:SCOPE
																clientID:CLIENT_ID
															clientSecret:API_SECRET
														keychainItemName:KEYCHAIN_ID
														  resourceBundle:nil] autorelease];
	
	// Optional: display some html briefly before the sign-in page loads
	NSString *html = @"<html><body><div align=center>Loading sign-in page...</div></body></html>";
	[windowController setInitialHTMLString:html];
	
	windowController.shouldPersistUser = YES;
	
	[windowController signInSheetModalForWindow:window
									   delegate:self
							   finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void) loadAuth:(NSString*) authStr
{
	auth = [GTMOAuth2WindowController authForGoogleFromKeychainForName:KEYCHAIN_ID
															  clientID:CLIENT_ID
														  clientSecret:API_SECRET];
	
}

- (NSString*) authStr
{
	return [auth persistenceResponseString];
}
@end
