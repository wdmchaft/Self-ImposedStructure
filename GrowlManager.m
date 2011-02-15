//
//  GrowlDelegate.m
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "GrowlManager.h"
#import "Context.h"
#import "Reporter.h"

@implementation GrowlManager
@synthesize alertQ, savedQ;
@synthesize timer;
@dynamic category;
@dynamic name; 
@dynamic enabled;
- (id) init
{
	NSLog(@"GrowlDelegate started");
	if (self){
		[GrowlApplicationBridge setGrowlDelegate:self];
		alertQ = [NSMutableArray new];
		savedQ = [NSMutableArray new];
		[self performSelector:@selector(growlLoop:)];
	}
	return self;
}

- (void) clearQueues
{
	alertQ = [NSMutableArray new];
	savedQ = [NSMutableArray new];
}

-(void) saveAlert: (Note*) alert
{
	if ([savedQ containsObject: alert]){
	//	NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[savedQ addObject:alert];
}

-(void) queueAlert: (Note*) alert
{
	if ([alertQ containsObject: alert]){
	//	NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[alertQ addObject:alert];
}

-(void) handleError: (Note*) error
{
	<Reporter> sender = [[[Context sharedContext] instancesMap] objectForKey:error.moduleName];
	
	[GrowlApplicationBridge
	 notifyWithTitle:@"Error!"
	 description:error.message
	 notificationName:@"Error Alert"
	 iconData:[[Context sharedContext]iconForModule:((<Instance>)sender)]
	 priority:0
	 isSticky:YES
	 clickContext:nil];
}

-(void) handleAlert:(Note*) alert 
{
	Context *ctx = [Context sharedContext];
	// ignore when flagged as lastAlert -- means a refresh cycle is complete
	if (alert.lastAlert){
		NSLog(@"cycle ended for %@", alert.moduleName);
		return;
	}
	if (ctx.currentState == WPASTATE_FREE) {
		[self queueAlert:alert];
	}
	else {
		if ([alert urgent] == YES ){
			[self queueAlert:alert];
		} else {
			[self saveAlert: alert];
		}
	}
	
}

- (void) growlThis: (NSString*) this
{
	[GrowlApplicationBridge
	 notifyWithTitle: @"FYI"
	 description:this
	 notificationName:@"WPA Alert"
	 iconData:[[Context sharedContext]iconForModule:nil]
	 priority:0
	 isSticky:NO
	 clickContext: nil];
}

-(void) growlAlert: (Note*) alert
{
//	NSLog(@"showing alert %@", alert.message);
	<Reporter> sender = [[[Context sharedContext] instancesMap] objectForKey:alert.moduleName];
	
	
	[GrowlApplicationBridge
	 notifyWithTitle: alert.title == nil ? sender.notificationTitle : alert.title
	 description:alert.message
	 notificationName:sender.notificationName
	 iconData:[[Context sharedContext]iconForModule:((<Instance>)sender)]
	 priority:0
	 isSticky:alert.sticky
	 clickContext: alert.clickable ? alert.params : nil];
}

- (void) growlNotificationWasClicked:(id)ctx 
{
	<Reporter> callMod = [[Context sharedContext].instancesMap objectForKey:[ctx objectForKey: @"module"]];
	
	[callMod handleClick:ctx];
	
}

-(void) growlLoop: (NSTimer*) timeIn;
{
	if (timer){
		[timer invalidate];
		timer = nil;
	}
	NSMutableArray *q =alertQ;
	//	NSLogDebug(@"Checking Q...");
	if ([q count] > 0){
		[self growlAlert:[q objectAtIndex:0]];
		[q removeObjectAtIndex:0];
	}
	NSTimeInterval gIInt = [[NSUserDefaults standardUserDefaults] doubleForKey:@"growlFrequency"];
	//[self performSelector:@selector(growlLoop:) withObject:nil afterDelay:interval];
	timer = [NSTimer scheduledTimerWithTimeInterval:gIInt
													  target:self 
													selector:@selector(growlLoop:)
													userInfo:nil
													 repeats:NO]; 
}

- (void) changeState:(WPAStateType)newState
{
	switch (newState) {
		case WPASTATE_FREE:
			[self freeState];
			break;
		case WPASTATE_AWAY:
			[self awayState];
			break;
		case WPASTATE_THINKING:
			[self workState];
			break;
		default:
			break;
	}
}

- (void) freeState
{	
	// first dump everything saved into the growl queue...
	while ([savedQ count] > 0) {
		Note *moveAlert = [savedQ objectAtIndex:0];
		[alertQ insertObject: moveAlert atIndex:0];
		[savedQ removeObjectAtIndex:0];
	} 
}

 - (void) awayState
{
	// dump everything (EVERYTHING) in the growl queue into save queue...
	
	while ([alertQ count] > 0) {
		Note *moveAlert = [alertQ objectAtIndex:0];
		[savedQ addObject: moveAlert];
		[alertQ removeObjectAtIndex:0];
	} 
}

- (void) workState
{
	NSMutableArray	*replaceQ = [[NSMutableArray alloc] initWithCapacity:10];
	while ([alertQ count] > 0) {
		Note *moveAlert = [alertQ objectAtIndex:0];
		if (moveAlert.urgent) {
			[replaceQ addObject: moveAlert];
		} else {
			[savedQ addObject:moveAlert];
		}
		[alertQ removeObjectAtIndex:0];
	} 
	alertQ = replaceQ;
}

- (void) stop
{
	[timer invalidate];
	timer = nil;
	[GrowlApplicationBridge setGrowlDelegate:nil];

}
- (void) finalize {
	if (timer){
		[timer invalidate];
		timer = nil;
	}
	[super finalize];
}
-(void)loadDefaults{}
-(void)clearDefaults{}
- (void) startValidation:(NSObject*) handler{}
-(void)clearValidation{}
-(void) saveDefaults{}
@end
