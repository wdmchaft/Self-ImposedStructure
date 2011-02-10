//
//  Context.m
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

//#import "BaseModule.h"
#import "IconsFile.h"
#import "TaskInfo.h"
#import "State.h"
#import "Utility.h"
#import "BaseInstance.h"
#import "TaskList.h"
#import "Reporter.h"
#import "Stateful.h"
#import "GrowlManager.h"

@interface Context : NSObject {
	NSMutableDictionary *instancesMap; // maps module name to instance of module
	NSMutableDictionary *bundlesMap; // maps plugin name to its bundle
	NSMutableDictionary *iconsMap; // maps module name to its icon;
	int growlInterval;
	BOOL startOnLoad;
	BOOL loadOnLogin;
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
	WPAStateType currentState;
	GrowlManager *growlManager;
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
@property (nonatomic) WPAStateType currentState;
@property (nonatomic) int thinkTime;
@property (nonatomic, retain) NSString *alertName;
@property (nonatomic, retain) TaskInfo *currentTask;
//@property (nonatomic, retain) NSString *currentSource;
@property (nonatomic, retain) NSManagedObject *currentActivity;
@property (nonatomic, retain) NSArray *tasksList;
@property (nonatomic, retain) NSDate *lastStateChange;
@property (nonatomic, retain) GrowlManager *growlManager;
@property (nonatomic) NSTimeInterval timeAwayThreshold;
@property (nonatomic) NSTimeInterval brbThreshold;
@property (nonatomic) WPAStateType previousState;
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

@end


@implementation Context
//@synthesize alertQ;
@synthesize growlInterval;
@synthesize running;
@synthesize bundlesMap;
@synthesize startOnLoad;
@synthesize instancesMap;
@synthesize iconsMap;
@synthesize currentState;
@synthesize thinkTime;
@synthesize loadOnLogin;
@synthesize alertName;
@synthesize currentActivity;
@synthesize currentTask;
@synthesize ignoreScreenSaver;
@synthesize tasksList;
@synthesize weeklyGoal;
@synthesize dailyGoal;
@synthesize lastStateChange;
@synthesize previousState;
@synthesize timeAwayThreshold;
@synthesize brbThreshold;
@synthesize autoBackToWork;
@synthesize showSummary;
@synthesize growlManager;


static Context* sharedContext = nil;

+ (Context*)sharedContext;
{
    if (sharedContext == nil) {
		sharedContext = [[super allocWithZone:NULL] init];
	//	[sharedContext clearModules];
		[sharedContext loadBundles];
		[sharedContext initFromDefaults];

	}
    return sharedContext;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedContext] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void) loadBundles
{
	NSBundle *me = [NSBundle mainBundle];
	NSString *bId = [me bundleIdentifier];
	NSArray *ids = [bId componentsSeparatedByString:@"."];
	NSString *appName = [ids objectAtIndex:[ids count] - 1];
	NSLog(@"%@", appName);
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	bundlesMap = [[NSMutableDictionary alloc]initWithCapacity:6];
	NSFileManager *dfm = [NSFileManager defaultManager];
	for (NSString *path in paths){
		NSError *err = [NSError new];
		NSString *nudgePath = [path stringByAppendingFormat:@"/%@/Plugins", appName];
		NSArray *fileNames = [dfm contentsOfDirectoryAtPath:nudgePath error: &err];
		for (NSString *fileName in fileNames){
			if ([fileName hasSuffix:@".bundle"]){
				NSString *fullBundlePath=[nudgePath stringByAppendingFormat:@"%@%@",@"/",fileName];
				NSBundle *bundle = [[NSBundle alloc]initWithPath:fullBundlePath];
				NSString *pluginName = [[dfm displayNameAtPath:fileName] stringByDeletingPathExtension];
				[bundlesMap setObject:bundle forKey:pluginName];
			}
		}
	}
}

- (TaskInfo*) readTask:(NSUserDefaults*) ud
{
	NSObject *task = [ud objectForKey:@"currentTask"];
	NSObject *source = [ud objectForKey:@"currentSource"];
	if (task){
		TaskInfo *info = [[TaskInfo alloc] init];
		info.name = (NSString*)task;
		if (source){
			info.source = (<TaskList>)[instancesMap objectForKey:(NSString*) source];
		}
		return info;
	}
	return nil;
}

- (void) saveTask
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud removeObjectForKey:@"currentTask"];
	[ud removeObjectForKey:@"currentSource"];

	if (currentTask){
		[ud setObject:currentTask.name forKey:@"currentTask"];
		if (currentTask.source){
			<TaskList> src = currentTask.source;
			NSString *srcName = ((NSObject*)src).description;
			[ud setObject:srcName forKey:@"currentSource"];
		} 
	}
}

- (void) initFromDefaults
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	NSObject *temp = [ud objectForKey:@"StartOnLoad"];
	if (temp != nil){
		startOnLoad = [((NSNumber*) temp) intValue];
		running = startOnLoad; // set running according to this -- we will be starting up ASAP
	}
	temp = [ud objectForKey:@"LoadOnLogin"];
	if (temp != nil){
		loadOnLogin = [((NSNumber*) temp) intValue];
	}
	
	/**
	 If this is the first time the the initial state is OFF
	 **/
	temp = [ud objectForKey:@"CurrentState"];
	[self setCurrentState: temp ? [((NSNumber*) temp) intValue] : WPASTATE_OFF]; // 
	
	temp = [ud objectForKey:@"PreviousState"];
	previousState = temp? [((NSNumber*) temp) intValue] : WPASTATE_FREE;
					 
	temp = [ud objectForKey:@"IgnoreScreenSaver"];
	if (temp != nil){
		ignoreScreenSaver = [((NSNumber*) temp) intValue];
	}
	temp = [ud objectForKey:@"GrowlInterval"];
	growlInterval = (temp == nil) ? 10 : [((NSNumber*) temp) intValue];
	
	temp = [ud objectForKey:@"DailyGoal"];
	dailyGoal = (temp == nil) ? 0 : [((NSNumber*) temp) intValue];
	
	temp = [ud objectForKey:@"WeeklyGoal"];
	weeklyGoal = (temp == nil) ? 0 : [((NSNumber*) temp) intValue];
	
	temp = [ud objectForKey:@"ThinkTime"];
	thinkTime =(temp == nil) ? 30 : [((NSNumber*) temp) intValue];
	
	temp = [ud objectForKey:@"AlertName"];
	alertName = (temp == nil) ? @"Beep" : (NSString*)temp;
	
	temp = [ud objectForKey:@"ShowSummary"];
	showSummary = (temp ? [((NSNumber*) temp) intValue] : YES);
	
	temp = [ud objectForKey:@"AutoBackToWork"];
	autoBackToWork = (temp ? [((NSNumber*) temp) intValue] : YES);
	
	temp = [ud objectForKey:@"BRBThreshold"];
	brbThreshold = (temp ? [((NSNumber*) temp) intValue] : 10 * 60);
	
	temp = [ud objectForKey:@"TimeAwayThreshold"];
	timeAwayThreshold = (temp ? [((NSNumber*) temp) intValue] : 4 * 60 * 60);
		
	temp = [ud objectForKey:@"LastStateChange"];
	lastStateChange = (temp ? (NSDate*) temp : [NSDate distantPast]);

	
	// ModulesList : <modName1>, <pluginNameY>, <modName2>, <pluginNameX>, <modName3>, <pluginNameZ>, etc...
	
	NSString *modsStr = [ud stringForKey:@"ModulesList"];

	NSArray *modsAndTypes = [modsStr componentsSeparatedByString:@","];
	int count = [modsAndTypes count] / 2;
	NSMutableDictionary *modulesMap = [[NSMutableDictionary alloc]initWithCapacity: count];
	for (int i = 0; i < count;i++) {
		int idx1 = i * 2;
		int idx2 = idx1 + 1;
		NSString *name = [Utility decode:[modsAndTypes objectAtIndex:idx1]];
		NSString *pluginName = [modsAndTypes objectAtIndex:idx2];
		// 
		// lookup the pluginName vs the map of actual existing plugins (plugins that *have* bundles)
		// only add a module to the map if it has a corresponding plugin
		//
		NSObject *piBundle = [bundlesMap objectForKey:pluginName];
		if (piBundle){
			[modulesMap setObject:pluginName forKey:name];
		} else {
		}
	}

	instancesMap = [[NSMutableDictionary alloc]initWithCapacity:count];
	
	// and finally instantiate each module
	for (NSString *modName in modulesMap){
		NSString *bundleName = [modulesMap objectForKey:modName];
		NSBundle *bundle = [bundlesMap objectForKey: bundleName]; 
 		Class modClass = bundle.principalClass;
		BaseInstance *mod = [modClass alloc];
		//
		// the NIB name should match the plugin
		//
		mod = [mod initWithNibName:bundleName bundle:bundle];
		mod.name = modName;
		[instancesMap setObject: mod forKey:modName];
		[mod loadDefaults];
	}
	// this depends on having the instances map set
	currentTask = [self readTask:ud];
}

-(void) saveDefaults
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject: [NSNumber numberWithInt:startOnLoad] forKey: @"StartOnLoad"];
	[ud setObject: [NSNumber numberWithInt:loadOnLogin] forKey: @"LoadOnLogin"];
	[ud setObject: [NSNumber numberWithInt:ignoreScreenSaver] forKey: @"IgnoreScreenSaver"];
	[ud setObject: [NSNumber numberWithInt:currentState] forKey: @"currentState"];
	[ud setObject: [NSNumber numberWithInt:thinkTime] forKey: @"ThinkTime"];
	[ud setObject: [NSNumber numberWithInt:growlInterval] forKey: @"GrowlInterval"];
	[ud setObject: [NSNumber numberWithInt:thinkTime] forKey: @"ThinkTime"];
	[ud setObject: [NSNumber numberWithInt:weeklyGoal] forKey: @"WeeklyGoal"];
	[ud setObject: [NSNumber numberWithInt:dailyGoal] forKey: @"DailyGoal"];
	[ud setObject: [NSNumber numberWithInt:timeAwayThreshold] forKey: @"TimeAwayThreshold"];
	[ud setObject: [NSNumber numberWithInt:brbThreshold] forKey: @"BRBThreshold"];
	[ud setObject: [NSNumber numberWithInt:autoBackToWork] forKey: @"AutoBackToWork"];
	[ud setObject: [NSNumber numberWithInt:showSummary] forKey: @"ShowSummary"];
	[ud setObject: [NSNumber numberWithInt:previousState] forKey: @"PreviousState"];
	[ud setObject: lastStateChange forKey: @"LastStateChange"];
	[ud setObject: alertName forKey: @"AlertName"];
	[self saveModules];
	[self saveTask];
	
	[ud synchronize];
	
}

- (void) removeDefaultsForKey: (NSString*) keyPrefix
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	for (NSString *key in [[ud dictionaryRepresentation] allKeys]){
		if ([key hasPrefix:keyPrefix]) {
			[ud removeObjectForKey:keyPrefix];
		}
	}
}

-(void) saveModules
{
	NSString *modsString = @"";
	for (NSString *name in [instancesMap allKeys]){
		NSString *escName = [Utility encode:name];
		NSString *comma = [modsString length] == 0?@"" : @",";
		modsString = [modsString stringByAppendingString:comma];
		modsString = [modsString stringByAppendingString:escName];
		comma = [modsString length] == 0?@"" : @",";
		modsString = [modsString stringByAppendingString:comma];
		NSString *type = [[[instancesMap objectForKey:name] class] description];
		modsString = [modsString stringByAppendingString:type];
		
	}
	[[NSUserDefaults standardUserDefaults] setObject: modsString forKey:@"ModulesList"];
}

-(void) clearModules
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ModulesList"];

}

- (NSString*) descriptionForModule: (NSObject*) mod 
{
	Class clz = [mod class];
	NSBundle *bundle = [bundlesMap objectForKey: [clz description]];
	NSString *dispName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	return dispName;
}

- (NSData*) iconForModule: (<Instance>) mod 
{
	NSString *name = [[((NSObject*)mod) class]description];
	if (iconsMap == nil){
		iconsMap = [[NSMutableDictionary alloc]initWithCapacity:[bundlesMap count]];
	}
	if (name == nil){
		NSString *path = [NSString stringWithFormat:@"%@/wpa.ico",[[NSBundle mainBundle] resourcePath]];
		return [NSData dataWithContentsOfFile:path];
	}
	if ([[iconsMap allKeys] indexOfObject:name] == NSNotFound) {
		
		NSBundle *bundle = [bundlesMap objectForKey: name];
		NSString *iconName = [bundle objectForInfoDictionaryKey:@"CFBundleIconFile"];
		NSString *path = [bundle resourcePath];
		path = [path stringByAppendingFormat:@"/%@",iconName];
		NSData *data = [NSData dataWithContentsOfFile:path];
		NSData *iconData = nil;
		if ([path hasSuffix: @"ico"]) {
			iconData = data;
		}
		else {
			IconsFile *iFile = [[IconsFile alloc]init];
			[iFile loadIconData:data];
			iconData = [iFile getIconForHeight:32];
		}
		[iconsMap setObject:iconData forKey:name ];
	}
	NSData *ret = [iconsMap objectForKey:name];
	return ret;
}

- (void) setCurrentState:(WPAStateType) newState;
{
	previousState = currentState;
	currentState = newState;
	lastStateChange = [NSDate new];
}

- (void) busyModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		<Stateful> inst = (<Stateful>) thing;
		if ( ((<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
			[inst changeState: WPASTATE_THINKING];
		}
	}
	[growlManager changeState: WPASTATE_THINKING];
}

- (void) freeModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		<Stateful> inst = (<Stateful>) thing;
		if ( ((<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
			[inst changeState: WPASTATE_FREE];
		}
	}
	[growlManager changeState: WPASTATE_FREE];
}

- (void) awayModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		<Stateful> inst = (<Stateful>) thing;
		if ( ((<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
			[inst changeState: WPASTATE_AWAY];
		}		
	}
	[growlManager changeState: WPASTATE_AWAY];
}	

- (void) stopModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		<Stateful> inst = (<Stateful>) thing;
		if ( ((<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
			[inst changeState: WPASTATE_OFF];
		}		
	}
	[growlManager changeState: WPASTATE_OFF];
}

- (NSArray*) refreshableModules
{
	NSMutableArray *ret = [NSMutableArray new];
	for (NSString *name in instancesMap){
		id thing = [instancesMap objectForKey: name];
		<Instance> inst = (<Instance>) thing;
		if ( inst.enabled && [thing conformsToProtocol:@protocol(Reporter)]){
			if (((<Reporter>)thing).refreshInterval) { // only add it if the refresh interval is sane
				[ret addObject:thing];
			}
		}
	}
	return [NSArray arrayWithArray:ret];
}


-(void) refreshTasks
{
	NSDictionary *modules = [[Context sharedContext] instancesMap];

	<Instance> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled && [module conformsToProtocol:@protocol(TaskList)]){
			[ ( (<TaskList>) module) refreshTasks];
		}
	}
}

- (NSArray*) getTasks {
	NSMutableDictionary *gather = [NSMutableDictionary new];
	<TaskList> module = nil;
	NSString *name = nil;
	for (name in instancesMap){
		id thing = [instancesMap objectForKey: name];
		<TaskList> list  = (<TaskList>) thing;
		<Instance> inst  = (<Instance>) thing;
		if (inst.enabled && [thing conformsToProtocol:@protocol(TaskList)]){
			NSArray *items = [list getTasks];
			if (items){
				for(NSString *item in items){
					TaskInfo *info = [[TaskInfo alloc] initWithName:item 
															source : module 
															project:[module projectForTask:item]];
					TaskInfo *fo = [gather objectForKey:info.name];
					if (fo){
						fo.description = [NSString stringWithFormat:@"%@ [%@]",
										  fo.name,
										  [((NSObject*)fo.source) description] ];
						info.description = [NSString stringWithFormat:@"%@ [%@]",
											info.name,
											[((NSObject*)info.source) description] ];
					}
					[gather setObject:info forKey:info.description];
				}
			}
		}
	}
	return [gather allValues];
}
@end


