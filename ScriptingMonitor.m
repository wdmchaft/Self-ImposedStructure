//
//  ScriptingMonitor.m
//  WorkPlayAway
//
//  Created by Charles on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScriptingMonitor.h"
/*
 * single-thread execution of applescripts from multiple plugin instances against an executable (ical or mail) 
 * also handle the scenario where an applescript hangs
 *
 * the protocol for the caller is to send the script in a script message along with a complete message identifier string
 * whose queue the caller listens on.
 * when the complete message is received the caller can safely access the results of the script execution until
 * it sends a done message back. If another caller sends a script message before the first caller sends done, then 
 * script message is queued until the first caller gets a done message.
 */


@implementation ScriptingMonitor
@synthesize stopMe;
@synthesize lastStart;
@synthesize eventRes;
@synthesize errorRes;
@synthesize callbackQueue;
@synthesize scriptQueue;
@synthesize scriptThread;
@synthesize prefix;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        callbackQueue = [NSMutableArray new];
        scriptQueue = [NSMutableArray new];
		lastStart = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void) runScriptThread: (NSObject*) param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"running script");
	NSAssert([scriptQueue count] > 0,@"scriptQueue is empty!");
	NSString *script = [scriptQueue objectAtIndex:0];
	NSString *callback = [callbackQueue objectAtIndex:0];
    NSAppleScript *aScript = [[NSAppleScript alloc] initWithSource:script];
    errorRes = nil;
    eventRes = [aScript executeAndReturnError:&errorRes];
    NSNotification *msg = [NSNotification notificationWithName:callback object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:msg];
	[pool drain];	
}

- (void) runScript: (NSNotification*) msg
{
    NSDictionary *dict = [msg userInfo];
    NSString *script = [dict objectForKey:@"script"];
    NSString *callback = [dict objectForKey:@"callback"];
	
	[scriptQueue addObject:script];
	[callbackQueue addObject:callback];
    
    if (lastStart){
		return;
    }
    else {
        lastStart = [NSDate date];
		scriptThread = [[NSThread alloc]initWithTarget: self 
											  selector: @selector(runScriptThread:)
												object:nil];
		[scriptThread start];
    }
}

- (void) doDone: (NSNotification*) msg
{
    NSLog(@"got done");
    [scriptQueue removeObjectAtIndex:0];
    [callbackQueue removeObjectAtIndex:0];
    if ([scriptQueue count] > 0){
        
		lastStart = [NSDate date];
        if (scriptThread){
            [scriptThread cancel];
        }
		scriptThread = [[NSThread alloc]initWithTarget: self 
											  selector: @selector(runScriptThread:)
												object:nil];
		[scriptThread start];     
    }
    else {
        lastStart = nil;
    }
}

- (void) sendScript: (NSString*) script withCallback: (NSString*) callback
{
    NSString *msgName = [NSString stringWithFormat:@"%@Script",prefix];
    NSDictionary *msgDict = [NSDictionary dictionaryWithObjectsAndKeys:script, @"script" , callback, @"callback", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:msgName object:self userInfo:msgDict];
}

- (void) sendDone
{
    NSString *msgName = [NSString stringWithFormat:@"%@Done",prefix];
    [[NSNotificationCenter defaultCenter] postNotificationName:msgName object:self userInfo:nil];
}

/**
 * Sadly apple scripts sometimes hang.  If this occurs kill the thread so we can try again. (and not hang)
 */
- (void) checkScript: (NSTimer*) timer
{
	if (lastStart && scriptThread) {
		NSTimeInterval maxDuration = [[NSUserDefaults standardUserDefaults] doubleForKey:@"maxAppleScriptTime"];
		NSTimeInterval scriptDuration = [lastStart timeIntervalSinceNow] * -1;
		// cancel the thread,
		// tell the caller it is complete with an error
		
		if (scriptDuration > maxDuration){
			[scriptThread cancel];
			scriptThread = nil;
			NSString *err = [NSString stringWithFormat:@"%@ script timed out after %f seconds", prefix, scriptDuration];
			NSLog(@"%@",err);
			errorRes = [NSDictionary dictionaryWithObject:err forKey:@"error"];
			
			NSString *callback = [callbackQueue objectAtIndex:0];
			
			NSNotification *msg = [NSNotification notificationWithName:callback object:nil];
			[[NSNotificationCenter defaultCenter] postNotification:msg];
			;	
		}
	}
}

- (void) monLoop: (NSObject*) param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	// Create and schedule the first timer.
	NSTimeInterval saveInt = 2;
	NSDate* futureDate = [NSDate dateWithTimeIntervalSinceNow:saveInt];
	NSTimer* myTimer = [[NSTimer alloc] initWithFireDate:futureDate
												interval:saveInt
												  target:self
												selector:@selector(checkScript:)
												userInfo:nil
												 repeats:YES];
	[runLoop addTimer:myTimer forMode:NSDefaultRunLoopMode];
    
	
    NSString *msgName1 = [NSString stringWithFormat:@"%@Script",prefix];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(runScript:) 
												 name:msgName1 
											   object:nil];
    
    NSString *msgName2 = [NSString stringWithFormat:@"%@Done",prefix];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(doDone:) 
												 name:msgName2 
											   object:nil];
    
    //	while (!stopMe && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	double resolution = 300.0;
	BOOL isRunning;
	do {
		// run the loop!
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
    NSThread *monitorThread = [[NSThread alloc] initWithTarget:self selector:@selector(monLoop:) object:nil];
	[monitorThread start];
}

+ (void)initialize{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 
								 [NSNumber numberWithDouble:30.0],	@"maxAppleScriptTime",
								 nil];
	
    [defaults registerDefaults:appDefaults];
	
	
}


@end

