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
	NSDictionary *currentTask;
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
}

@property (nonatomic, retain) NSMutableDictionary *instancesMap;
@property (nonatomic, retain) NSMutableDictionary *bundlesMap;
@property (nonatomic, retain) NSMutableDictionary *iconsMap;
@property (nonatomic) BOOL running;
@property (nonatomic) int thinkTime;
@property (nonatomic,retain) NSTimer *nagDelayTimer;
@property (nonatomic, retain) NSDictionary *currentTask;
//@property (nonatomic, retain) NSString *currentSource;
@property (nonatomic, retain) NSManagedObject *currentActivity;
@property (nonatomic, retain) NSArray *tasksList;
@property (nonatomic) WPAStateType currentState;
@property (nonatomic, readonly) WPAStateType previousState;
@property (nonatomic,retain) GrowlManager *growlManager;
@property (nonatomic,retain) HUDSettings *hudSettings;
@property (nonatomic,retain) HeatMap *heatMapSettings;
@property (nonatomic,retain) TotalsManager *totalsManager;
@property (nonatomic, retain) NDHotKeyEvent *hotkeyEvent;

+ (Context*)sharedContext;
- (void) loadBundles;
- (void) initFromDefaults;
- (void) saveModules;
- (void) saveDefaults;
- (void) saveTask;
- (NSDictionary*) readTask:(NSUserDefaults*) defaults;
- (NSString*) descriptionForModule: (NSObject*) mod;
- (NSData*) iconForModule: (id<Instance>) mod;
- (void) removeDefaultsForKey: (NSString*) keyPrefix;

- (void) refreshModules: (id<AlertHandler>) handler withLoop: (BOOL) loopingOn;
- (void) scheduleModules: (id<AlertHandler>) handler withLoop: (BOOL) loopingOn;
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

@end
