//
//  GrowlDelegate.m
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
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

-(void) saveAlert: (WPAAlert*) alert
{
	if ([savedQ containsObject: alert]){
	//	NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[savedQ addObject:alert];
}

-(void) queueAlert: (WPAAlert*) alert
{
	if ([alertQ containsObject: alert]){
	//	NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[alertQ addObject:alert];
}

-(void) handleError: (WPAAlert*) error
{
	id<Reporter> sender = [[[Context sharedContext] instancesMap] objectForKey:error.moduleName];
	
	[GrowlApplicationBridge
	 notifyWithTitle:@"Error!"
	 description:error.message
	 notificationName:@"Error Alert"
	 iconData:[[Context sharedContext]iconForModule:((id<Instance>)sender)]
	 priority:0
	 isSticky:YES
	 clickContext:nil];
}

-(void) handleAlert:(WPAAlert*) alert 
{
	Context *ctx = [Context sharedContext];
	// ignore when flagged as lastAlert -- means a refresh cycle is complete
	if (alert.lastAlert){
		NSLog(@"cycle ended for %@", alert.moduleName);
		return;
	}
    if (ctx.currentState == WPASTATE_FREE && ctx.nagDelayTimer == nil) {
        [self queueAlert:alert];
    }
    else if (ctx.currentState == WPASTATE_VACATION && [alert isWork] == NO){
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
- (void) growlFYI:(NSString *)this
{
    [self growlThis:this isSticky:NO withTitle: @"FYI"];
}

- (void) growlThis: (NSString*) this isSticky: (BOOL) sticky withTitle:(NSString*) title
{
	[GrowlApplicationBridge
	 notifyWithTitle: title
	 description:this
	 notificationName:@"WPA Alert"
	 iconData:[[Context sharedContext]iconForModule:nil]
	 priority:0
	 isSticky:sticky
	 clickContext: nil];
}

-(void) growlAlert: (WPAAlert*) alert
{
//	NSLog(@"showing alert %@", alert.message);
	id<Reporter> sender = [[[Context sharedContext] instancesMap] objectForKey:alert.moduleName];
	
	
	[GrowlApplicationBridge
	 notifyWithTitle: alert.title == nil ? sender.notificationTitle : alert.title
	 description:alert.message
	 notificationName:sender.notificationName
	 iconData:[[Context sharedContext]iconForModule:((id<Instance>)sender)]
	 priority:0
	 isSticky:alert.sticky
	 clickContext: alert.clickable ? alert.params : nil];
}

- (void) growlNotificationWasClicked:(id)ctx 
{
	id <Reporter> callMod = [[Context sharedContext].instancesMap objectForKey:[ctx objectForKey: @"module"]];
	
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
		case WPASTATE_VACATION:
			[self vacationState];
			break;
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
		WPAAlert *moveAlert = [savedQ objectAtIndex:0];
		[alertQ insertObject: moveAlert atIndex:0];
		[savedQ removeObjectAtIndex:0];
	} 
}

 - (void) awayState
{
	// dump everything (EVERYTHING) in the growl queue into save queue...
	
	while ([alertQ count] > 0) {
		WPAAlert *moveAlert = [alertQ objectAtIndex:0];
		[savedQ addObject: moveAlert];
		[alertQ removeObjectAtIndex:0];
	} 
}

- (void) vacationState
{
	NSMutableArray	*replaceQ = [[NSMutableArray alloc] initWithCapacity:10];
	while ([alertQ count] > 0) {
		WPAAlert *moveAlert = [alertQ objectAtIndex:0];
		if (moveAlert.urgent) {
			[replaceQ addObject: moveAlert];
        } 
        else if (!moveAlert.isWork){
            [replaceQ addObject: moveAlert];	
        } 
        else {
			[savedQ addObject:moveAlert];
		}
		[alertQ removeObjectAtIndex:0];
	} 
	alertQ = replaceQ;
}

- (void) workState
{
	NSMutableArray	*replaceQ = [[NSMutableArray alloc] initWithCapacity:10];
	while ([alertQ count] > 0) {
		WPAAlert *moveAlert = [alertQ objectAtIndex:0];
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

-(id)copyWithZone: (NSZone*)zone {
    return [[[self class] allocWithZone:zone] init];
}

@end
