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
#import "HUDSettings.h"

@interface Context : NSObject {
	NSMutableDictionary *instancesMap; // maps module name to instance of module
	NSMutableDictionary *bundlesMap; // maps plugin name to its bundle
	NSMutableDictionary *iconsMap; // maps module name to its icon;
	BOOL startOnLoad;
	WPAStateType currentState;
	int thinkTime;
	TaskInfo *currentTask;
	NSManagedObject *currentActivity;
	BOOL running;
	NSArray *tasksList;
	WPAStateType previousState;
	GrowlManager *growlManager;
	HUDSettings *hudSettings;
}

@property (nonatomic, retain) NSMutableDictionary *instancesMap;
@property (nonatomic, retain) NSMutableDictionary *bundlesMap;
@property (nonatomic, retain) NSMutableDictionary *iconsMap;
@property (nonatomic) BOOL running;
@property (nonatomic) int thinkTime;
@property (nonatomic, retain) TaskInfo *currentTask;
//@property (nonatomic, retain) NSString *currentSource;
@property (nonatomic, retain) NSManagedObject *currentActivity;
@property (nonatomic, retain) NSArray *tasksList;
@property (nonatomic) WPAStateType currentState;
@property (nonatomic, readonly) WPAStateType previousState;
@property (nonatomic,retain) GrowlManager *growlManager;
@property (nonatomic,retain) HUDSettings *hudSettings;

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
- (void) stopModules ;
- (void) refreshTasks;
- (NSArray*) refreshableModules;
- (NSArray*) getTasks ;


@end
