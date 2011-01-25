//
//  BaseModule.m
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//
#define ENABLED @"Enabled"

#import "BaseModule.h"

@implementation BaseModule
@synthesize started;
@synthesize enabled;
@synthesize description;
@synthesize notificationTitle;
@synthesize notificationName;
@synthesize sticky;
@synthesize handler;
@synthesize lastError;
@synthesize validationHandler;
@synthesize detailController;
@synthesize away;
@synthesize thinking;
@synthesize type;
@synthesize skipRefresh;

-(void) think
{
	thinking = YES;
}
-(void) putter;
{
	thinking = NO;
}

-(void) stop
{
	started = NO;
}

-(void) goAway
{
	away = YES;
}

-(void) handleClick:(NSDictionary*) ctx
{
}

-(void) setAlertCallback:(<AlertHandler>) hndl
{	
	handler = hndl;
} 
- (void) sendError: (NSString*) error module:(NSString*) modName
{
	Note *alert = [[Note alloc]init];
	alert.moduleName = modName;
	alert.title =nil;
	alert.message=error;
	alert.params = nil;
	[handler handleError: alert];
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

+ (NSString*) encode: (NSString*) inStr
{
	NSString *out = [inStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	out = [out stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
	return out;
}

+ (NSString*) decode: (NSString*) inStr
{
	NSString *out = [inStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	out = [out stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
	return out;
}

-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key
{
	NSString *myKey = [[NSString alloc]initWithFormat:@"%@.%@",[BaseModule encode:description],key];
	[[NSUserDefaults standardUserDefaults] setObject:val forKey:myKey];
}

-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key
{
	NSString *myKey = [[NSString alloc]initWithFormat:@"%@.%@",[BaseModule encode:description],key];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:myKey];
}

-(id) loadDefaultForKey: (NSString*) key
{
	NSString *myKey = [[NSString alloc]initWithFormat:@"%@.%@",[BaseModule encode:description],key];
	return [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
}

-(NSArray*) trackingItems
{
	return nil;
}

-(void) refreshTasks
{
}

// should be overridden
- (void) getSummary
{
	[self sendSummaryDone];
}

- (void) sendSummaryDone
{
	Note *alert = [[Note alloc]init];
	alert.moduleName = [self description];
	alert.params = [NSDictionary new]; // empty - not nil
	[handler handleAlert:alert];
}

- (NSString*) projectForTask: (NSString*) task
{
	return nil;
}
@end
