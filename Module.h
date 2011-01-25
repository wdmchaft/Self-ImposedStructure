//
//  Module.h
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlertHandler.h"
//#define MODULE_CAL 1
//#define MODULE_TODO 2;
//#define MODULE_EMAIL 3
//#define MODULE_CHAT 4

typedef enum {
	MODULE_OTHER, MODULE_EVENTS, MODULE_EMAIL, MODULE_CHAT_CONTROL, MODULE_TASKS
} WPAModuleType;

@protocol Module <NSObject>

- (NSView*) view;
- (void) think;
- (void) putter;
- (void) stop;
- (void) goAway;
- (BOOL) started;
- (void) handleClick: (NSDictionary*) ctx;
- (void) startValidation:(NSObject*) handler;
- (void) clearValidation;
- (void) saveDefaults;
- (void) loadDefaults;
- (void) clearDefaults;
- (void) refreshTasks;
- (void) getSummary;

- (NSString*) projectForTask: (NSString*) task;

@property (nonatomic, retain) NSString* description;
@property (nonatomic) WPAModuleType type;
@property (nonatomic) BOOL started;
@property (nonatomic) BOOL thinking;
@property (nonatomic) BOOL sticky;
@property (nonatomic) BOOL enabled;
@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, retain) NSString* notificationTitle;
@property (nonatomic, retain) <AlertHandler> handler;
@property (nonatomic, retain) NSString* lastError;
@property (nonatomic,readonly) NSArray* trackingItems;
@property (nonatomic) BOOL skipRefresh;
@end
