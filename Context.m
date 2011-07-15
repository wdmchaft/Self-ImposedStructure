//
//  Context.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "Context.h"
#import "IconsFile.h"
#import "State.h"
#import "Utility.h"
#import "BaseInstance.h"
#import "TaskList.h"
#import "Reporter.h"
#import "Stateful.h"
#import "GrowlManager.h"
#import "HUDSettings.h"
#import "HeatMap.h"
#import "TotalsManager.h"
#import "NDHotKeyEvent.h"


@implementation Context
//@synthesize alertQ;
@synthesize running;
@synthesize bundlesMap;
@synthesize instancesMap;
@synthesize iconsMap;
@synthesize currentState;
@synthesize thinkTime;
@synthesize currentActivity;
@synthesize currentProject;
@synthesize tasksList;
@synthesize previousState;
@synthesize growlManager;
@synthesize hudSettings;
@synthesize heatMapSettings;
@synthesize totalsManager;
@synthesize nagDelayTimer;
@synthesize hotkeyEvent;
@synthesize params;
@synthesize debug;
@synthesize queueName;

static Context* sharedContext = nil;

+ (Context*)sharedContext;
{
    if (sharedContext == nil) {
#if DEBUG
		sharedContext.debug = YES;
#endif
		sharedContext = [[super allocWithZone:NULL] init];
		sharedContext.queueName = @"com.zer0gravitas.devstruct";
		if ([__APPNAME__ isEqualToString:@"Self-Imposed Structure"]) {
			sharedContext.queueName = @"com.zer0gravitas.selfstruct";
		}	
		[sharedContext loadBundles];
		[sharedContext initFromDefaults];
		sharedContext.hudSettings = [[HUDSettings alloc]init];
		[sharedContext.hudSettings readFromDefaults];
		sharedContext.heatMapSettings = [[HeatMap alloc] init];
		sharedContext.debug = NO;
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
	//NSBundle *me = [NSBundle mainBundle];
	//NSString *bId = [me bundleIdentifier];
	//NSArray *ids = [bId componentsSeparatedByString:@"."];
	NSString *appName =  __APPNAME__;
	//NSLog(@"%@", appName); 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	bundlesMap = [[NSMutableDictionary alloc]initWithCapacity:6];
	NSFileManager *dfm = [NSFileManager defaultManager];
	for (NSString *path in paths){
		NSError *err = [NSError new];
		NSString *nudgePath = [path stringByAppendingFormat:@"/%@/Plugins", appName];
#if DEBUG
		NSLog(@"nudgePath = %@", nudgePath);
#endif
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

- (NSDictionary*) readTask:(NSUserDefaults*) ud
{
	NSDictionary *task = [ud objectForKey:@"currentTask"];
	return task;
}

- (void) saveTask
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSObject *temp = [ud objectForKey:@"currentTask"];
	if (temp){
		[ud removeObjectForKey:@"currentTask"];
	}

	if (_currentTask){
		[ud setObject:_currentTask forKey:@"currentTask"];
	}
}

- (void) initFromDefaults
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	running = [ud boolForKey:@"startOnLoad"];// set running according to this -- we will be starting up ASAP

	/**
	 If this is the first time the the initial state is OFF
	 **/
	currentState = [ud integerForKey:@"currentState"];
	previousState = [ud integerForKey:@"previousState"];
			 
	thinkTime =[ud doubleForKey:@"thinkTime"];
		
	
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
	
	params = [NSDictionary dictionaryWithObjectsAndKeys:
			  [NSNumber numberWithBool:debug], @"debug",
			  queueName, @"queuename",
			  nil];
	// and finally instantiate each module
	for (NSString *modName in modulesMap){
		NSString *bundleName = [modulesMap objectForKey:modName];
		NSBundle *bundle = [bundlesMap objectForKey: bundleName]; 
 		Class modClass = bundle.principalClass;
		BaseInstance *mod = [modClass alloc];
		//
		// the NIB name should match the plugin
		//
		mod = [mod initWithNibName:bundleName bundle:bundle params:params];
		mod.name = modName;
		[instancesMap setObject: mod forKey:modName];
		[mod loadDefaults];
	}
	// this depends on having the instances map set
	_currentTask = [self readTask:ud];
	
	int keyCode = [ud integerForKey:@"keyCode"];
	if (keyCode != 0){
		int keyModifiers = [ud integerForKey:@"keyModifiers"];
		hotkeyEvent = [NDHotKeyEvent getHotKeyForKeyCode:keyCode modifierFlags:keyModifiers];
	}
}

-(void) saveDefaults
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

	[ud setObject: [NSNumber numberWithInt:currentState] forKey: @"currentState"];
	[ud setObject: [NSNumber numberWithInt:thinkTime] forKey: @"thinkTime"];
	[ud setObject: [NSNumber numberWithInt:previousState] forKey: @"previousState"];
	[self saveModules];
	[self saveTask];
	[hudSettings saveToDefaults];
	[heatMapSettings save];
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
- (void) saveHUDSettings
{
	
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

- (NSImage*) iconImageForModule: (id<Instance>) mod 
{	
	NSData *data = [self iconForModule:mod];
	if (!data){
		return nil;
	}
	return [[NSImage alloc]initWithData:data];
}

- (NSData*) iconForModule: (id<Instance>) mod 
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
			if (iconData == nil){
				//NSLog(@"Can not load icon file: [%@]", path);
				NSString *path = [NSString stringWithFormat:@"%@/wpa.ico",[[NSBundle mainBundle] resourcePath]];
				return [NSData dataWithContentsOfFile:path];
			}
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
	[[NSUserDefaults standardUserDefaults] setObject: [NSDate new] forKey:@"lastStateChange"];
}

- (void) vacationModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		id<Stateful> inst = (id<Stateful>) thing;
		if ( ((id<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
#ifdef DEBUG
		//	NSLog(@"making %@ vacate", inst);
#endif
			[inst changeState: WPASTATE_VACATION];
		}
	}
	[growlManager changeState: WPASTATE_VACATION];
}

- (void) busyModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		id<Stateful> inst = (id<Stateful>) thing;
		if ( ((id<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
#ifdef DEBUG
		//	NSLog(@"making %@ work", inst);
#endif
			[inst changeState: WPASTATE_THINKING];
		}
	}
	[growlManager changeState: WPASTATE_THINKING];
}

- (void) freeModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		id<Stateful> inst = (id<Stateful>) thing;
		if ( ((id<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
#ifdef DEBUG
	//		NSLog(@"making %@ free", inst);
#endif
			[inst changeState: WPASTATE_FREE];
		}
	}
	[growlManager changeState: WPASTATE_FREE];
}

- (void) awayModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		id<Stateful> inst = (id<Stateful>) thing;
		if ( ((id<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
#ifdef DEBUG
		//	NSLog(@"making %@ away", inst);
#endif			
			[inst changeState: WPASTATE_AWAY];
		}		
	}
	[growlManager changeState: WPASTATE_AWAY];
}	

- (void) stopModules {
	for (NSString *name in instancesMap){
		NSObject* thing = [instancesMap objectForKey: name];
		id<Stateful> inst = (id<Stateful>) thing;
		if ( ((id<Instance>)inst).enabled && [thing conformsToProtocol:@protocol(Stateful)]){
#ifdef DEBUG
		//	NSLog(@"making %@ off", inst);
#endif			
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
		id<Instance> inst = (id<Instance>) thing;
		if ( inst.enabled && [thing conformsToProtocol:@protocol(Reporter)]){
			if (((id<Reporter>)thing).refreshInterval) { // only add it if the refresh interval is sane
				[ret addObject:thing];
			}
		}
	}
	return [NSArray arrayWithArray:ret];
}


-(void) refreshTasks
{
	NSDictionary *modules = [[Context sharedContext] instancesMap];

	id<Instance> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled && [module conformsToProtocol:@protocol(TaskList)]){
			[ ( (id<TaskList>) module) refreshTasks];
		}
	}
}

- (NSArray*) getTasks {
	NSMutableArray *gather = [NSMutableArray new];
	NSString *name = nil;
	for (name in instancesMap){
		id thing = [instancesMap objectForKey: name];
		id<TaskList> list  = (id<TaskList>) thing;
		id<Instance> inst  = (id<Instance>) thing;
//		NSString *proj = nil;
		if (inst.enabled && [thing conformsToProtocol:@protocol(TaskList)]){
			NSArray *items = [list getTasks];
			if (items){
				for(NSDictionary *item in items){
					[gather addObject:item ];
				}
			}
		}
	}
	return gather;
}

- (NSArray*) getTaskLists {
	NSMutableArray *gather = [NSMutableArray new];
	NSString *name = nil;
	for (name in instancesMap){
		id thing = [instancesMap objectForKey: name];
//		id<TaskList> list  = (id<TaskList>) thing;
		id<Instance> inst  = (id<Instance>) thing;
		//		NSString *proj = nil;
		if (inst.enabled && [thing conformsToProtocol:@protocol(TaskList)]){
			[gather addObject: thing];
		}
	}
	return gather;
}	

- (NSArray*) getTrackedLists {
	NSMutableArray *gather = [NSMutableArray new];
	NSString *name = nil;
	for (name in instancesMap){
		id thing = [instancesMap objectForKey: name];
		id<Instance> inst  = (id<Instance>) thing;
		if (inst.enabled && [thing conformsToProtocol:@protocol(TaskList)]){
			id<TaskList> list = (<TaskList>) thing;
			if ([list tracked]){
				[gather addObject: thing];
			}
		}
	}
	return gather;
}

- (GrowlManager*) growlManager 
{
    if (!growlManager){
        growlManager = [GrowlManager new];
    }
    return growlManager;
}

- (BOOL) isWorkingState
{
	return currentState == WPASTATE_AWAY || currentState == WPASTATE_THINKING
		|| currentState == WPASTATE_THINKTIME || currentState == WPASTATE_FREE;
}

- (void) endNagDelay: (NSTimer*) timer
{
	[nagDelayTimer invalidate];
	nagDelayTimer = nil;
}

- (void) startNagDelay
{
	double delay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"nagDelayTime"];
	nagDelayTimer = [NSTimer scheduledTimerWithTimeInterval:delay 
														 target:self 
													   selector:@selector(endNagDelay:) 
													   userInfo:nil 
														repeats:NO];
}

+ (NSString*) defaultTaskName
{
	NSDateFormatter *stampFmt = [NSDateFormatter new];
	[stampFmt setDateStyle:NSDateFormatterShortStyle];
	[stampFmt setTimeStyle:NSDateFormatterShortStyle];
	NSString *stamp = [stampFmt stringFromDate:[NSDate date]];
	return [NSString stringWithFormat:@"Miscellaneous starting at %@",stamp];
}

+ (NSDictionary*) defaultTask
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
	 [Context defaultTaskName], @"name",
	 @"Uncategorized", @"project",
	 nil];
}

- (void) setCurrentTask:(NSDictionary *) dict
{
	if (!dict) {
		_currentTask = [Context defaultTask];
	}
	else {
		_currentTask = [dict copy];
	}
}

- (NSDictionary*) currentTask
{
	if (!_currentTask){
		_currentTask = [Context defaultTask];	
	}
	return _currentTask;
}
@end


