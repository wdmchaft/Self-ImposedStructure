//
//  BaseInstance.m
//  WorkPlayAway
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "BaseInstance.h"
#import "Utility.h"

@implementation BaseInstance
@synthesize enabled;
@synthesize name;
@synthesize notificationTitle;
@synthesize notificationName;
@synthesize validationHandler;
@synthesize detailController;
@synthesize category;
@synthesize refreshInterval;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
	if (self) {
		refreshInterval = 15 * 60;
	}
	return self;
}

-(void) startValidation: (NSObject*) callback  
{
	validationHandler = callback;
}
- (void) clearValidation
{
	validationHandler = nil;
}
-(void) saveDefaults{
	[self saveDefaultValue:[NSNumber numberWithInt:enabled] forKey:ENABLED];
}

-(void) clearDefaults{
	[self clearDefaultValue:[NSNumber numberWithInt:enabled] forKey:ENABLED];
}

-(void) loadDefaults{
	NSNumber *temp = [self loadDefaultForKey:ENABLED];
	enabled = [temp intValue];
}

-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key
{
	NSString *myKey = [self myKeyForKey:key];
	[[NSUserDefaults standardUserDefaults] setObject:val forKey:myKey];
}

- (NSString*) myKeyForKey: (NSString*) key 
{
       return [[NSString alloc]initWithFormat:@"%@.%@",[Utility encode:name],key];
}

-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key
{
	NSString *myKey = [self myKeyForKey:key];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:myKey];
}

-(id) loadDefaultForKey: (NSString*) key
{
	NSString *myKey = [self myKeyForKey:key];
	return [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
}

- (BOOL) loadBoolDefaultForKey: (NSString*) key
{
	NSString *myKey = [self myKeyForKey:key];
	return [[NSUserDefaults standardUserDefaults] boolForKey:myKey];
}

+ (void) sendErrorToHandler:(id<AlertHandler>) handler error:(NSString*) err module:(NSString*) modName
{
	WPAAlert *alert = [[WPAAlert alloc]init];
	alert.moduleName = modName;
	alert.title =nil;
	alert.message=err;
	alert.params = nil;
	[handler handleError: alert];
}

+ (void) sendDone: (id<AlertHandler>) handler module: (NSString*) modName
{
	WPAAlert *alert = [[WPAAlert alloc]init];
	alert.moduleName = modName;
	alert.lastAlert = YES;
	[handler handleAlert: alert];
}

-(id)copyWithZone: (NSZone*)zone {
    return [[[self class] allocWithZone:zone] init];
}

@end
