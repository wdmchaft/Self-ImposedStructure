//
//  RTMProtocol.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/28/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"
#import "TaskList.h"
@interface RouteInfo : NSObject
{
	NSObject *target;
	SEL method;
	SEL step2;
	NSString *timeline;
	NSMutableDictionary *params;
	BOOL ok;
}

@property (nonatomic, retain) NSObject *target;
@property (nonatomic, retain) NSString *timeline ;
@property (nonatomic, retain) NSMutableDictionary *params ;
@property (nonatomic, assign) SEL method;
@property (nonatomic, assign) SEL step2;
@property (nonatomic, assign) BOOL ok;
- (id) initWithTarget: (NSObject *) target selector: (SEL) method step2: (SEL) next params: (NSDictionary*) dict;
- (void) timelineRequest: (NSObject*) target callback: (SEL) cb nextStep: (SEL) s2 params: (NSDictionary*) dict;
- (void) sendMoveTo2: (RouteInfo*) info;
- (void) sendNote: (NSObject*) target 
		 callback: (SEL) cb 
		   newVal: (NSString *) newNote oldVal: (NSString*) old
			 task: (NSDictionary*) tdc;
@end
@interface RTMProtocol : NSObject {
	NSString *tokenStr;
	NSString *userStr;
	NSString *passwordStr;
	NSString *frobStr;
	NSString *listNameStr;
	//NSDictionary *parameters;
	NSMutableDictionary *idMapping;
	NSMutableDictionary *tasksDict;
	NSString *listIdStr;
	NSMutableArray *tasksList;

	id<AlertHandler> handler;
	NSString *lastError;
	BaseReporter *module;
	NSMutableDictionary *workRouter;
	NSMutableArray *timelineQueue;
}

@property (nonatomic, retain) NSString *tokenStr;
@property (nonatomic, retain) NSString *frobStr;
@property (nonatomic, retain) NSString *userStr;
@property (nonatomic, retain) NSString *passwordStr;
@property (nonatomic, retain) NSString *listNameStr;
@property (nonatomic, retain) NSString *listIdStr;
@property (nonatomic, retain) NSMutableDictionary *idMapping;
@property (nonatomic, retain) NSMutableDictionary *tasksDict;
//@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic, retain) NSMutableArray *tasksList;
@property (nonatomic, retain) BaseReporter *module;

@property (nonatomic, retain) id<AlertHandler> handler;
@property (nonatomic, retain) NSString *lastError;
@property (nonatomic, retain) NSMutableDictionary *workRouter;
@property (nonatomic, retain) NSMutableArray *timelineQueue;

-(void) startRefresh: (NSObject*) target callback: (SEL) cb;
-(void) updateList: (NSObject*) target callback: (SEL) cb;

- (void) getToken: (NSObject*) target callback: (SEL) cb;
- (void) getFrob: (NSObject*) target callback: (SEL) cb;
- (NSString*) getAuthURL;
- (void) getLists: (NSObject*) target callback: (SEL) cb;
- (void) sendMoveTo: (NSObject*) target callback: (SEL) cb list: (NSString*) newList params: (NSDictionary*) tdc;
- (void) timelineRequest: (NSObject*) target callback: (SEL) cb nextStep: (SEL) s2 params: (NSDictionary*) dict;
- (void) sendComplete: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary;
- (void) sendAdd: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary;

- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) handleRTMError:(NSDictionary*) errInfo;
- (void) sendWithRoute: (RouteInfo*) info
			  returnTo: (NSObject*) target 
			  callback: (SEL) cb 
			methodName: (NSString*) method 
				params: (NSDictionary*) tdc
		   optionNames: (NSArray*) names;
- (void) sendSimple: (NSObject*) target 
		   callback: (SEL) cb 
		 methodName: (NSString*) method 
			 params: (NSDictionary*) tdc;
- (void) sendName: (NSObject*) target callback: (SEL) cb name: (NSString *) newName task: (NSDictionary*) tdc;
- (void) sendDate: (NSObject*) target callback: (SEL) cb date: (NSDate *) newDate task: (NSDictionary*) tdc;
- (void) sendNote: (NSObject*) target callback: (SEL) cb 
		   newVal: (NSString *) newNote oldVal: (NSString*) old
			 task: (NSDictionary*) tdc;
- (void) sendPriority: (NSObject*) target callback: (SEL) cb priority: (int) prio task: (NSDictionary*) tdc;

@end



