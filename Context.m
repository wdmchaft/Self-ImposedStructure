//
//  Context.m
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "Context.h"
#import "BaseModule.h"
#import "IconsFile.h"
#import "TaskInfo.h"

@implementation Context
@synthesize alertQ;
@synthesize growlInterval;
@synthesize running;
@synthesize thinkTimer;
@synthesize bundlesMap;
@synthesize startOnLoad;
@synthesize instancesMap;
@synthesize iconsMap;
@synthesize startingState;
@synthesize thinkTime;
@synthesize loadOnLogin;
@synthesize alertName;
@synthesize currentActivity;
@synthesize currentTask;
//@synthesize currentSource;
@synthesize ignoreScreenSaver;
@synthesize tasksList;

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
			info.source = (<Module>)[instancesMap objectForKey:(NSString*) source];
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
			<Module> src = currentTask.source;
			NSString *srcName = src.description;
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
	temp = [ud objectForKey:@"StartingState"];
	if (temp != nil){
		startingState = [((NSNumber*) temp) intValue];
	}
	temp = [ud objectForKey:@"IgnoreScreenSaver"];
	if (temp != nil){
		startingState = [((NSNumber*) temp) intValue];
	}
	temp = [ud objectForKey:@"GrowlInterval"];
	growlInterval = (temp == nil) ? 10 : [((NSNumber*) temp) intValue];
	
	temp = [ud objectForKey:@"ThinkTime"];
	thinkTime =(temp == nil) ? 30 : [((NSNumber*) temp) intValue];
	
	temp = [ud objectForKey:@"AlertName"];
	alertName = (temp == nil) ? @"Beep" : (NSString*)temp;

	
	// ModulesList : <modName1>, <pluginNameY>, <modName2>, <pluginNameX>, <modName3>, <pluginNameZ>, etc...
	
	NSString *modsStr = [ud stringForKey:@"ModulesList"];

	NSArray *modsAndTypes = [modsStr componentsSeparatedByString:@","];
	int count = [modsAndTypes count] / 2;
	NSMutableDictionary *modulesMap = [[NSMutableDictionary alloc]initWithCapacity: count];
	for (int i = 0; i < count;i++) {
		int idx1 = i * 2;
		int idx2 = idx1 + 1;
		NSString *name = [BaseModule decode:[modsAndTypes objectAtIndex:idx1]];
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
		BaseModule *mod = [modClass alloc];
		//
		// the NIB name should match the plugin
		//
		mod = [mod initWithNibName:bundleName bundle:bundle];
		mod.description = modName;
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
	[ud setObject: [NSNumber numberWithInt:startingState] forKey: @"StartingState"];
	[ud setObject: [NSNumber numberWithInt:thinkTime] forKey: @"ThinkTime"];
	[ud setObject: [NSNumber numberWithInt:growlInterval] forKey: @"GrowlInterval"];
	[ud setObject: [NSNumber numberWithInt:thinkTime] forKey: @"ThinkTime"];
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
		NSString *escName = [BaseModule encode:name];
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

- (NSString*) descriptionForModule: (<Module>) mod 
{
	Class clz = [mod class];
	NSBundle *bundle = [bundlesMap objectForKey: [clz description]];
	NSString *dispName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	return dispName;
}

- (NSData*) iconForModule: (<Module>) mod 
{
	NSString *name = [[mod class]description];
	if (iconsMap == nil){
		iconsMap = [[NSMutableDictionary alloc]initWithCapacity:[bundlesMap count]];
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

- (NSMutableArray*) savedQ
{
	if (!savedQ){
		savedQ = [NSMutableArray new];
	}
	return savedQ;
}

- (NSMutableArray*) alertQ
{
	if (!alertQ){
		alertQ = [NSMutableArray new];
	}
	return alertQ;
}
@end


