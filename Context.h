//
//  Context.h
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "Module.h"
#import "TaskInfo.h"


@interface Context : NSObject {
	NSMutableDictionary *instancesMap; // maps module name to instance of module
	NSMutableDictionary *bundlesMap; // maps plugin name to its bundle
	NSMutableDictionary *iconsMap; // maps module name to its icon;
	NSMutableArray *savedQ;
	NSMutableArray *alertQ;
	int growlInterval;
	NSTimer *thinkTimer;
	BOOL startOnLoad;
	BOOL loadOnLogin;
	int startingState;
	int thinkTime;
	NSString *alertName;
	TaskInfo *currentTask;
//	NSString *currentSource;
	NSManagedObject *currentActivity;
	BOOL ignoreScreenSaver;
	BOOL running;
	NSArray *tasksList;
}

@property (nonatomic, retain) NSMutableDictionary *instancesMap;
@property (nonatomic, retain) NSMutableDictionary *bundlesMap;
@property (nonatomic, retain) NSMutableDictionary *iconsMap;
@property (nonatomic, retain, readonly) NSMutableArray *savedQ;
@property (nonatomic, retain) NSMutableArray *alertQ;
@property (nonatomic) int growlInterval;
@property (nonatomic, retain) NSTimer *thinkTimer;
@property (nonatomic) BOOL startOnLoad;
@property (nonatomic) BOOL loadOnLogin;
@property (nonatomic) BOOL ignoreScreenSaver;
@property (nonatomic) BOOL running;
@property (nonatomic) int startingState;
@property (nonatomic) int thinkTime;
@property (nonatomic, retain) NSString *alertName;
@property (nonatomic, retain) TaskInfo *currentTask;
//@property (nonatomic, retain) NSString *currentSource;
@property (nonatomic, retain) NSManagedObject *currentActivity;
@property (nonatomic, retain) NSArray *tasksList;

+ (Context*)sharedContext;
- (void) loadBundles;
- (void) initFromDefaults;
- (void) saveModules;
- (void) saveDefaults;
- (void) saveTask;
- (TaskInfo*) readTask:(NSUserDefaults*) defaults;
- (NSString*) descriptionForModule: (<Module>) mod;
- (NSData*) iconForModule: (<Module>) mod;
- (void) removeDefaultsForKey: (NSString*) keyPrefix;

@end
