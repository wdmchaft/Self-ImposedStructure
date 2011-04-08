//
//  iCalMonitor.m
//  WorkPlayAway
//
//  Created by Charles on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iCalMonitor.h"


@implementation iCalMonitor
@synthesize stopMe;
@synthesize busy;
@synthesize eventRes;
@synthesize errorRes;
@synthesize callbackQueue;
@synthesize scriptQueue;

static iCalMonitor* iCalShared = nil;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        callbackQueue = [NSMutableArray new];
        scriptQueue = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void) runScript: (NSString*) script forCallback: (NSString*) callback
{
    NSLog(@"running script");
    NSAppleScript *aScript = [[NSAppleScript alloc] initWithSource:script];
    errorRes = nil;
    eventRes = [aScript executeAndReturnError:&errorRes];
    NSNotification *msg = [NSNotification notificationWithName:callback object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:msg];   
}

- (void) runScript: (NSNotification*) msg
{
    NSDictionary *dict = [msg userInfo];
    NSString *script = [dict objectForKey:@"script"];
    NSString *callback = [dict objectForKey:@"callback"];

    if (busy){
        [scriptQueue addObject:script];
        [callbackQueue addObject:callback];
    }
    else {
        busy = YES;
        [self runScript:script forCallback:callback];
    }
}

- (void) doDone: (NSNotification*) msg
{
    NSLog(@"got done");
    if ([scriptQueue count] > 0){
        NSString *script = [scriptQueue objectAtIndex: 0];
        NSString *callback = [callbackQueue objectAtIndex:0];
        [scriptQueue removeObject:script];
        [callbackQueue removeObject:callback];
        [self runScript:script forCallback:callback];
     
    }
    else {
        busy = NO;
    }
}

- (void) sendScript: (NSString*) script withCallback: (NSString*) callback
{
    NSDictionary *msgDict = [NSDictionary dictionaryWithObjectsAndKeys:script, @"script" , callback, @"callback", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCalScript" object:self userInfo:msgDict];
}

- (void) sendDone
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCalDone" object:self userInfo:nil];

}
- (void) sayHello
{
    NSLog(@"hello");
}
- (void) monLoop: (NSObject*) param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	// Create and schedule the first timer.
	NSTimeInterval saveInt = 900;
	NSDate* futureDate = [NSDate dateWithTimeIntervalSinceNow:saveInt];
	NSTimer* myTimer = [[NSTimer alloc] initWithFireDate:futureDate
												interval:saveInt
												  target:self
												selector:@selector(sayHello)
												userInfo:nil
												 repeats:YES];
	[runLoop addTimer:myTimer forMode:NSDefaultRunLoopMode];
    
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(runScript:) 
												 name:@"iCalScript" 
											   object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(doDone:) 
												 name:@"iCalDone" 
											   object:nil];
    
    //	while (!stopMe && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	double resolution = 300.0;
	BOOL isRunning;
	do {
		// run the loop!
		NSLog(@"in run loop");
		NSDate* theNextDate = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
		isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate]; 
		// occasionally re-create the autorelease pool whilst program is running
		[pool drain];
		pool = [[NSAutoreleasePool alloc] init];            
	} while(isRunning==YES && stopMe==NO);
	
	[pool drain];
}

- (void) startLoop
{
    NSThread *ioThread = [[NSThread alloc] initWithTarget:self selector:@selector(monLoop:) object:nil];
	[ioThread start];
}

+(iCalMonitor*) iCalShared
{
    if (!iCalShared){
        iCalShared = [iCalMonitor new];
        [iCalShared startLoop];
    }
    return iCalShared;
}

@end
