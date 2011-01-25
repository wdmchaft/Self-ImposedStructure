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
@synthesize description;
@synthesize notificationTitle;
@synthesize notificationName;
@synthesize validationHandler;
@synthesize detailController;
@synthesize category;
@synthesize refreshInterval;


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
	NSString *myKey = [[NSString alloc]initWithFormat:@"%@.%@",[Utility encode:description],key];
	[[NSUserDefaults standardUserDefaults] setObject:val forKey:myKey];
}

-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key
{
	NSString *myKey = [[NSString alloc]initWithFormat:@"%@.%@",[Utility encode:description],key];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:myKey];
}

-(id) loadDefaultForKey: (NSString*) key
{
	NSString *myKey = [[NSString alloc]initWithFormat:@"%@.%@",[Utility encode:description],key];
	return [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
}

+ (void) sendErrorToHandler:(<AlertHandler>) handler error:(NSString*) err module:(NSString*) modName
{
	Note *alert = [[Note alloc]init];
	alert.moduleName = modName;
	alert.title =nil;
	alert.message=err;
	alert.params = nil;
	[handler handleError: alert];
}
+ (void) sendDone:(<AlertHandler>) handler 
{
	Note *alert = [[Note alloc]init];
	alert.moduleName = [self description];
	alert.lastAlert = YES;
	[handler handleAlert:alert];
}
@end
