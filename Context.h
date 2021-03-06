//
//  Context.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "GrowlManager.h"
#import "HUDSettings.h"
#import "HeatMap.h"
#import "TotalsManager.h"
#import "NDHotKeyEvent.h"

@interface Context : NSObject {
	NSMutableDictionary *instancesMap; // maps module name to instance of module
	NSMutableDictionary *bundlesMap; // maps plugin name to its bundle
	NSMutableDictionary *iconsMap; // maps module name to its icon;
	BOOL startOnLoad;
	WPAStateType currentState;
	int thinkTime;
	NSDictionary *_currentTask;
	NSString *currentProject;
	NSManagedObject *currentActivity;
	BOOL running;
	NSArray *tasksList;
	WPAStateType previousState;
	GrowlManager *growlManager;
	HUDSettings *hudSettings;
	HeatMap *heatMapSettings;
    TotalsManager *totalsManager;
	NSTimer *nagDelayTimer;
	NDHotKeyEvent *hotkeyEvent;
	NSString *queueName;
	BOOL debug;
	NSDictionary *params;
	NSString  *defaultSource;
}

@property (nonatomic, retain) NSMutableDictionary *instancesMap;
@property (nonatomic, retain) NSMutableDictionary *bundlesMap;
@property (nonatomic, retain) NSMutableDictionary *iconsMap;
@property (nonatomic) BOOL running;
@property (nonatomic) int thinkTime;
@property (nonatomic,retain) NSTimer *nagDelayTimer;
//@property (nonatomic, retain) NSString *currentSource;
@property (nonatomic, retain) NSManagedObject *currentActivity;
@property (nonatomic, retain) NSString *currentProject;
@property (nonatomic, retain) NSArray *tasksList;
@property (nonatomic) WPAStateType currentState;
@property (nonatomic, readonly) WPAStateType previousState;
@property (nonatomic, retain) GrowlManager *growlManager;
@property (nonatomic, retain) HUDSettings *hudSettings;
@property (nonatomic, retain) HeatMap *heatMapSettings;
@property (nonatomic, retain) TotalsManager *totalsManager;
@property (nonatomic, retain) NDHotKeyEvent *hotkeyEvent;
@property (nonatomic, retain) NSString *queueName;
@property (nonatomic, assign) BOOL	debug;
@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic, retain) NSString *defaultSource;

+ (Context*)sharedContext;
- (void) loadBundles;
- (void) initFromDefaults;
- (void) saveModules;
- (void) saveDefaults;
- (void) saveTask;
- (NSDictionary*) readTask:(NSUserDefaults*) defaults;
- (NSString*) descriptionForModule: (NSObject*) mod;
- (NSData*) iconForModule: (id<Instance>) mod;
- (NSImage*) iconImageForModule: (id<Instance>) mod;
- (void) removeDefaultsForKey: (NSString*) keyPrefix;

- (void) busyModules ;
- (void) freeModules ;
- (void) awayModules ;
- (void) stopModules ;
- (void) vacationModules ;
- (void) refreshTasks;
- (BOOL) isWorkingState;
- (NSArray*) refreshableModules;
- (NSArray*) getTasks ;
- (GrowlManager*) growlManager;
- (void) endNagDelay: (NSTimer*) timer;
- (void) startNagDelay;
- (NSArray*) getTaskLists;
- (NSArray*) getTrackedLists;
- (NSDictionary*) currentTask;
- (void) setCurrentTask:(NSDictionary *) dict;
+ (NSString*) defaultTaskName;
+ (NSDictionary*) defaultTask;
- (BOOL) addActivitiesEnabled;
- (BOOL) switchActivitiesEnabled;
- (void) modulesChanged;
@end
