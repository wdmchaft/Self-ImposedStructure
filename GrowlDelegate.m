//
//  GrowlDelegate.m
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "GrowlDelegate.h"
#import "Context.h"
#import "Reporter.h"

@implementation GrowlDelegate
@synthesize alertQ, savedQ;
@synthesize timer;
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

-(void) saveAlert: (Note*) alert
{
	Context *ctx = [Context sharedContext];
	if ([ctx.savedQ containsObject: alert]){
		NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[ctx.savedQ addObject:alert];
}

-(void) queueAlert: (Note*) alert
{
	Context *ctx = [Context sharedContext];
	if ([ctx.alertQ containsObject: alert]){
		NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[[Context sharedContext].alertQ addObject:alert];
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
			NSLog(@"saved %@",alert.message);
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
	NSLog(@"showing alert %@", alert.message);
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
	NSMutableArray *q = [[Context sharedContext]alertQ];
	//	NSLogDebug(@"Checking Q...");
	if ([q count] > 0){
		[self growlAlert:[q objectAtIndex:0]];
		[q removeObjectAtIndex:0];
	}
	int interval = [Context sharedContext].growlInterval;
	//[self performSelector:@selector(growlLoop:) withObject:nil afterDelay:interval];
	timer = [NSTimer scheduledTimerWithTimeInterval:interval
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
@end
