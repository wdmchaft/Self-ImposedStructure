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

@interface RTMProtocol : NSObject {
	NSString *tokenStr;
	NSString *userStr;
	NSString *passwordStr;
	NSString *frobStr;
	NSString *listNameStr;
	NSMutableString *timelineStr;
	//NSDictionary *parameters;
	NSMutableDictionary *idMapping;
	NSMutableDictionary *tasksDict;
	NSString *listIdStr;
	NSMutableArray *tasksList;

	id<AlertHandler> handler;
	NSString *lastError;
	BaseReporter *module;

}

@property (nonatomic, retain) NSString *tokenStr;
@property (nonatomic, retain) NSString *frobStr;
@property (nonatomic, retain) NSString *userStr;
@property (nonatomic, retain) NSString *passwordStr;
@property (nonatomic, retain) NSString *listNameStr;
@property (nonatomic, retain) NSString *listIdStr;
@property (nonatomic, retain) NSMutableString *timelineStr;
@property (nonatomic, retain) NSMutableDictionary *idMapping;
@property (nonatomic, retain) NSMutableDictionary *tasksDict;
//@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic, retain) NSMutableArray *tasksList;
@property (nonatomic, retain) BaseReporter *module;

@property (nonatomic, retain) id<AlertHandler> handler;
@property (nonatomic, retain) NSString *lastError;


-(void) startRefresh: (NSObject*) target callback: (SEL) cb;
-(void) updateList: (NSObject*) target callback: (SEL) cb;

- (void) getToken: (NSObject*) target callback: (SEL) cb;
- (void) getFrob: (NSObject*) target callback: (SEL) cb;
- (NSString*) getAuthURL;
- (void) getLists: (NSObject*) target callback: (SEL) cb;
- (void) sendRm: (NSObject*) target callback: (SEL) cb methodName: (NSString*) method params: (NSDictionary*) tdc;
- (void) sendMoveTo: (NSObject*) target callback: (SEL) cb list: (NSString*) newList params: (NSDictionary*) tdc;
- (void) timelineRequest: (NSObject*) target callback: (SEL) cb;
- (void) sendComplete: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary;
- (void) sendAdd: (NSObject*) target callback: (SEL) cb params: (NSDictionary*) dictionary;

- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) handleRTMError:(NSDictionary*) errInfo;

@end
