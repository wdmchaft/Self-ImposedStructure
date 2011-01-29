//
//  Context.h
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "TaskInfo.h"
#import "GrowlManager.h"

@interface Context : NSObject {
	NSMutableDictionary *instancesMap; // maps module name to instance of module
	NSMutableDictionary *bundlesMap; // maps plugin name to its bundle
	NSMutableDictionary *iconsMap; // maps module name to its icon;
	int growlInterval;
	NSTimer *thinkTimer;
	BOOL startOnLoad;
	BOOL loadOnLogin;
	WPAStateType currentState;
	int thinkTime;
	NSString *alertName;
	TaskInfo *currentTask;
	NSManagedObject *currentActivity;
	BOOL ignoreScreenSaver;
	BOOL running;
	NSArray *tasksList;
	NSTimeInterval dailyGoal;
	NSTimeInterval weeklyGoal;
	NSDate *lastStateChange;
	BOOL showSummary;
	BOOL autoBackToWork;
	NSTimeInterval timeAwayThreshold;
	NSTimeInterval brbThreshold;
	WPAStateType previousState;
	GrowlManager *growlDelegate;
}

@property (nonatomic, retain) NSMutableDictionary *instancesMap;
@property (nonatomic, retain) NSMutableDictionary *bundlesMap;
@property (nonatomic, retain) NSMutableDictionary *iconsMap;
@property (nonatomic) NSTimeInterval weeklyGoal;
@property (nonatomic) NSTimeInterval dailyGoal;
@property (nonatomic) int growlInterval;
@property (nonatomic, retain) NSTimer *thinkTimer;
@property (nonatomic) BOOL startOnLoad;
@property (nonatomic) BOOL loadOnLogin;
@property (nonatomic) BOOL ignoreScreenSaver;
@property (nonatomic) BOOL running;
@property (nonatomic) BOOL autoBackToWork;
@property (nonatomic) BOOL showSummary;
@property (nonatomic) int thinkTime;
@property (nonatomic, retain) NSString *alertName;
@property (nonatomic, retain) TaskInfo *currentTask;
//@property (nonatomic, retain) NSString *currentSource;
@property (nonatomic, retain) NSManagedObject *currentActivity;
@property (nonatomic, retain) NSArray *tasksList;
@property (nonatomic, retain) NSDate *lastStateChange;
@property (nonatomic) NSTimeInterval timeAwayThreshold;
@property (nonatomic) NSTimeInterval brbThreshold;
@property (nonatomic) WPAStateType currentState;
@property (nonatomic, readonly) WPAStateType previousState;
@property (nonatomic,retain) GrowlManager *growlDelegate;

+ (Context*)sharedContext;
- (void) loadBundles;
- (void) initFromDefaults;
- (void) saveModules;
- (void) saveDefaults;
- (void) saveTask;
- (TaskInfo*) readTask:(NSUserDefaults*) defaults;
- (NSString*) descriptionForModule: (NSObject*) mod;
- (NSData*) iconForModule: (<Instance>) mod;
- (void) removeDefaultsForKey: (NSString*) keyPrefix;

- (void) refreshModules: (<AlertHandler>) handler withLoop: (BOOL) loopingOn;
- (void) scheduleModules: (<AlertHandler>) handler withLoop: (BOOL) loopingOn;
- (void) busyModules ;
- (void) freeModules ;
- (void) awayModules ;
- (void) refreshTasks;
- (NSArray*) refreshableModules;
- (NSArray*) getTasks ;


@end
