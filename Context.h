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


@interface Context : NSObject {
	NSMutableDictionary *instancesMap; // maps module name to instance of module
	NSMutableDictionary *bundlesMap; // maps plugin name to its bundle
	NSMutableDictionary *iconsMap; // maps module name to its icon
	BOOL thinking;
	BOOL running;
	BOOL away;
	NSMutableArray *savedQ;
	NSMutableArray *alertQ;
	int growlInterval;
	NSTimer *thinkTimer;
	BOOL startOnLoad;
	BOOL loadOnLogin;
	int startingState;
	int thinkTime;
	NSString *alertName;
	NSString *currentTask;
	NSString *currentSource;
	NSManagedObject *currentActivity;
	BOOL ignoreScreenSaver;
}

@property (nonatomic, retain) NSMutableDictionary *instancesMap;
@property (nonatomic, retain) NSMutableDictionary *bundlesMap;
@property (nonatomic, retain) NSMutableDictionary *iconsMap;
@property (nonatomic, retain) NSMutableArray *savedQ;
@property (nonatomic, retain) NSMutableArray *alertQ;
@property (nonatomic) int growlInterval;
@property (nonatomic) BOOL thinking;
@property (nonatomic) BOOL running;
@property (nonatomic) BOOL away;
@property (nonatomic, retain) NSTimer *thinkTimer;
@property (nonatomic) BOOL startOnLoad;
@property (nonatomic) BOOL loadOnLogin;
@property (nonatomic) BOOL ignoreScreenSaver;
@property (nonatomic) int startingState;
@property (nonatomic) int thinkTime;
@property (nonatomic, retain) NSString *alertName;
@property (nonatomic, retain) NSString *currentTask;
@property (nonatomic, retain) NSString *currentSource;
@property (nonatomic, retain) NSManagedObject *currentActivity;

+ (Context*)sharedContext;
- (void) loadBundles;
- (void) initFromDefaults;
- (void) saveModules;
- (void) saveDefaults;
- (NSString*) descriptionForModule: (<Module>) mod;
- (NSData*) iconForModule: (<Module>) mod;

@end
