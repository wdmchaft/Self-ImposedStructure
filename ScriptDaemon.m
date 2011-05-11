//
//  ScriptDaemon.m
//  WorkPlayAway
//
//  Created by Charles on 5/9/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "ScriptDaemon.h"


@implementation ScriptDaemon
@synthesize sessionMap;
@synthesize stopMe;
@synthesize aseHandler;
@synthesize queueName;

- (id) initWithName: (NSString*) name
{
	self = [super init];
	if (self)
	{
		stopMe = NO;
		queueName = [[[NSString alloc]initWithFormat: @"%@", name] retain];
	}
	return self;
}


- (NSDictionary*) msgFromList: (NSMutableArray*) list forCallback: (NSString*) callback
{
	NSLog(@"msgFromList");
	NSDictionary *mailItem = [list objectAtIndex:0]; 
	[list removeObjectAtIndex:0];
	if ([list count] == 0) {
		NSLog(@"at EOF");
		[sessionMap removeObjectForKey:callback];
		[list release];
	}
	return mailItem;
}

-(void)handleNotification:(NSNotification*) notification
{
	NSLog(@"got notification");
	
	NSString *script = [[notification userInfo] objectForKey: @"script"];
	NSString *callback = [[notification userInfo] objectForKey: @"callback"];
	NSDictionary *errorRes = nil;
    NSAppleEventDescriptor *eventRes = nil;
	if (!sessionMap){
		sessionMap = [NSMutableDictionary new];
	}
	NSMutableArray *mailArray = [sessionMap objectForKey:callback];
	NSDictionary *msg;
	if (mailArray){
		NSLog(@"found session");
		msg = [self msgFromList:mailArray forCallback:callback];
	}
	else {
		NSLog(@"Starting new session with callback:\n%@",callback);
		NSAppleScript *aScript = [[NSAppleScript alloc] initWithSource:script];
		@try {
			NSLog(@"running script now");
			eventRes = [aScript executeAndReturnError:&errorRes];
			NSLog(@"done running script now");
		}
		@catch (NSException *exception) {
			errorRes = [NSDictionary dictionaryWithObject:exception.reason forKey:@"error"];
		}
		@finally {
		}
		if (!errorRes) {
			mailArray = [[NSMutableArray new] retain];
			
			[aseHandler handleEventDescriptor: eventRes list: mailArray];
			[sessionMap setObject:mailArray forKey:callback];
			NSLog(@"ok script result - %d messages", [mailArray count]);
			[mailArray addObject:[NSDictionary new]]; // add an empty dictionary -- EOF
			msg = [self msgFromList:mailArray forCallback:callback];
		}
		else {
			NSLog(@"bad script result %@", errorRes);	
			msg = [NSDictionary dictionaryWithObject:@"scripting error see log for details" forKey: @"error"];
		}
	}
	NSLog(@"returning response");
    [[NSDistributedNotificationCenter defaultCenter] 
	 postNotificationName:callback object:nil userInfo:msg deliverImmediately:YES];
}

- (void) doQuit: (NSNotification*) notification
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

	[NSApp stop:self];
}

- (void) putter: (NSTimer*) timer
{
	NSLog(@"%@ puttering", queueName);
}

- (void) loop: (NSAutoreleasePool*) pool
{	
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	// Create and schedule the first timer.
	NSTimeInterval saveInt = 600
	;
	NSDate* futureDate = [NSDate dateWithTimeIntervalSinceNow:saveInt];
	NSTimer* myTimer = [[NSTimer alloc] initWithFireDate:futureDate
												interval:saveInt
												  target:self
												selector:@selector(putter:)
												userInfo:nil
												 repeats:YES];
	[runLoop addTimer:myTimer forMode:NSDefaultRunLoopMode];
	
	NSLog(@"%@ listening", queueName);
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center addObserver:self 
			   selector:@selector(handleNotification:) 
				   name:queueName 
				 object:nil];
	
	NSString *quitQueue = [NSString stringWithFormat:@"%@.quit", queueName];
   	NSLog(@"%@ listening", quitQueue);
	[center addObserver:self 
			   selector:@selector(doQuit:) 
				   name:quitQueue 
				 object:nil]; 
	NSString *startedQueue = [NSString stringWithFormat:@"%@.started", queueName];
   	NSLog(@"%@ listening", startedQueue);

	[center postNotificationName:startedQueue object:nil]; // handshake to let the world know I am running
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
	
}

- (void) dealloc
{
	
	[sessionMap release];
	[queueName release];
	[super dealloc];
}

@end

