//
//  GrowlDelegate.m
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "GrowlDelegate.h"
#import "Context.h"

@implementation GrowlDelegate
@synthesize alertQ, savedQ;

- (id) init
{
	if (self){
		[GrowlApplicationBridge setGrowlDelegate:self];
		alertQ = [NSMutableArray new];
		savedQ = [NSMutableArray new];
		[self performSelector:@selector(growlLoop)];
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
	<Module> sender = [[[Context sharedContext] instancesMap] objectForKey:error.moduleName];
	
	[GrowlApplicationBridge
	 notifyWithTitle:@"Error!"
	 description:error.message
	 notificationName:@"Error Alert"
	 iconData:[[Context sharedContext]iconForModule:sender]
	 priority:0
	 isSticky:YES
	 clickContext:nil];
}

-(void) handleAlert:(Note*) alert 
{
	NSLog(@"received %@",alert.message);
	Context *ctx = [Context sharedContext];
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

-(void) growlAlert: (Note*) alert
{
	NSLog(@"showing alert %@", alert.message);
	<Module> sender = [[[Context sharedContext] instancesMap] objectForKey:alert.moduleName];
	
	
	[GrowlApplicationBridge
	 notifyWithTitle: alert.title == nil ? sender.notificationTitle : alert.title
	 description:alert.message
	 notificationName:sender.notificationName
	 iconData:[[Context sharedContext]iconForModule:sender]
	 priority:0
	 isSticky:alert.sticky
	 clickContext: alert.clickable ? alert.params : nil];
}

- (void) growlNotificationWasClicked:(id)ctx 
{
	<Module> callMod = [[Context sharedContext].instancesMap objectForKey:[ctx objectForKey: @"module"]];
	
	[callMod handleClick:ctx];
	
}

-(void) growlLoop: (NSTimer*) timer;
{
	[timer invalidate];
	timer = nil;
	NSMutableArray *q = [[Context sharedContext]alertQ];
	//	NSLogDebug(@"Checking Q...");
	if ([q count] > 0){
		[self growlAlert:[q objectAtIndex:0]];
		[q removeObjectAtIndex:0];
	}
	int interval = [Context sharedContext].growlInterval;
	[self performSelector:@selector(growlLoop) withObject:nil afterDelay:interval];
	timer = [NSTimer scheduledTimerWithTimeInterval:interval
													  target:self 
													selector:@selector(growlLoop:)
													userInfo:nil
													 repeats:NO]; 
}

- (void) finalize {
	if (timer){
		[timer invalidate];
		timer = nil;
	}
}
@end
