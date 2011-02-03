//
//  RefreshManager.m
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "RefreshManager.h"
#import "Context.h"
#import "Reporter.h"

@interface TimerInfo : NSObject
{
	NSTimer *timer;
	<Reporter> module;
}
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) id module;
@end

@implementation TimerInfo
@synthesize timer;
@synthesize module;

@end


@implementation RefreshManager
@synthesize timers;
@synthesize alertHandler;
@synthesize running;

- (id) initWithHandler:(<AlertHandler>) handler;
{
	if (self){ 
		Context *ctx = [Context sharedContext];
		NSArray *refreshable = [ctx refreshableModules];
		NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:[refreshable count]];
		for (id obj in refreshable){
			TimerInfo *info = [TimerInfo new];
			info.module = (<Reporter>)obj;
			[temp addObject: info];
		}
		timers = [[NSArray alloc]initWithArray:temp];
		alertHandler = handler;
	}
	return self;
}

- (void) startWithRefresh: (BOOL) doRefresh;
{
	NSLog(@"startWithRefresh: %@", doRefresh ? @"YES" : @"NO");
	running = YES;
	for (TimerInfo *info in timers){
		NSTimeInterval startInterval = doRefresh ? 0 : [info.module refreshInterval];
		NSLog(@"starting cycle for %@ in %d secs", [info.module description], [info.module refreshInterval]);
		info.timer = [NSTimer scheduledTimerWithTimeInterval:startInterval
													  target:self
													selector:@selector(doRefresh:) 
													  userInfo: info
													 repeats:NO];
	}
}

- (void) doRefresh: (NSTimer*) timer
{
	TimerInfo *info = (TimerInfo*)timer.userInfo;
	[info.timer invalidate];
	info.timer = nil;
	NSLog(@"doRefresh for %@", [info.module description]);
	if (running){
		[info.module refresh:alertHandler];
	}
	if (running){
		info.timer = [NSTimer scheduledTimerWithTimeInterval:[info.module refreshInterval] 
													  target:self
													selector:@selector(doRefresh:) 
													userInfo: info
													 repeats:NO];
	}
}

- (void)stop
{
	running = NO;
	for (TimerInfo *info in timers){
		[info.timer invalidate];
		info.timer = nil;
	}
}
@end
