//
//  GTProtocol.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/28/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"
#import "TaskList.h"
#import "GTMOAuth2Authentication.h"
#import "SBJSON.h"

#define API_SECRET @"lYSJuxP8hR2YJNJN87N22ZRU"
#define CLIENT_ID @"884448025606.apps.googleusercontent.com"
#define SCOPE @"https://www.googleapis.com/auth/tasks"
#define KEYCHAIN_ID @"GoogleTodoModule: Google Todos"
@interface SelWrapper : NSObject
{
	SEL selector;
}

@property (nonatomic, assign) SEL selector;

@end


@interface GTProtocol : NSObject {
	GTMOAuth2Authentication *auth;
	NSString *listNameStr;
	NSMutableString *timelineStr;
	//NSDictionary *parameters;
	NSMutableDictionary *idMapping;
	NSMutableDictionary *tasksDict;
	NSString *listIdStr;
	NSString *listLinkStr;
	NSMutableArray *tasksList;

	id<AlertHandler> handler;
	NSString *lastError;
	BaseReporter *module;
	SEL callback;
	NSObject *target;
	SEL step2Handler;
	SBJSON  *json;
	SEL errorCallback;
	NSMutableDictionary *saveTask;
	NSDateFormatter *dateFormatter;
	NSString *moveToListId;
}

@property (nonatomic, retain) NSString *listNameStr;
@property (nonatomic, retain) NSString *listIdStr;
@property (nonatomic, retain) NSMutableString *timelineStr;
@property (nonatomic, retain) NSString *listLinkStr;
@property (nonatomic, retain) NSMutableDictionary *idMapping;
@property (nonatomic, retain) NSMutableDictionary *tasksDict;
//@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic, retain) NSMutableArray *tasksList;
@property (nonatomic, retain) BaseReporter *module;

@property (nonatomic, retain) id<AlertHandler> handler;
@property (nonatomic, retain) NSString *lastError;
@property (nonatomic, retain) GTMOAuth2Authentication *auth;
@property (nonatomic, assign) SEL callback;
@property (nonatomic, assign) SEL errorCallback;
@property (nonatomic, retain) NSObject *target;
@property (nonatomic) SEL step2Handler;
@property (nonatomic,retain) SBJSON *json;
@property (nonatomic, retain) NSMutableDictionary *saveTask;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSString *moveToListId;

- (void) updateList:(NSObject*) caller returnTo:(SEL) cb;
- (void) getList:(NSObject*) caller returnTo:(SEL) cb;

- (void) getTokenInWindow: (NSWindow*) win handler:(NSObject*) retHandler returnTo: (SEL) cb;
- (void) getLists: (NSObject*) target returnTo: (SEL) cb;
- (void) sendDelete: (NSObject*) target returnTo: (SEL) cb params: (NSDictionary*) tdc;
- (void) sendMoveTo: (NSObject*) target returnTo: (SEL) cb list: (NSDictionary*) newList params: (NSMutableDictionary*) tdc;

- (void) sendAdd: (NSObject*) caller returnTo: (SEL) cb params: (NSDictionary*) newTask listId: (NSString*) idStr;
- (void) sendAdd: (NSObject*) caller returnTo: (SEL) cb params: (NSDictionary*) newTask list: (NSDictionary*) listData;

- (void) sendAdd: (NSObject*) caller returnTo: (SEL) cb params: (NSDictionary*) newTask;

- (void) sendComplete: (NSObject*) caller returnTo: (SEL) cb params:(NSDictionary*) task;
- (void) sendUpdate: (NSObject*) caller returnTo: (SEL) cb params:(NSMutableDictionary*) task;

- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) doSignInOnWindow: (NSWindow*) window;
- (void) loadAuth:(NSString*) authStr;
- (void) cacheDeleteTask: (NSDictionary*) task;
- (void) cacheUpdateTask: (NSDictionary*) task;
- (void) cacheAddTask: (NSDictionary*) task;

- (NSString*) authStr;
@end

@protocol GTProtocolErrorDelegate

- (void) gtProtocol: (GTProtocol*) proto callEndingAt: (SelWrapper*) selObj gotError: (NSError*) error;

@end
