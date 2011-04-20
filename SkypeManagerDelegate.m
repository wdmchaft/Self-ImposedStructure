//
//  SkypeManagerDelegate.m
//  WorkPlayAway
//
//  Created by Charles on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SkypeManagerDelegate.h"


@implementation SkypeManagerDelegate
@synthesize window;
@synthesize state;
@synthesize clientApplicationName;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	clientApplicationName=@"SkypeManager";
	[SkypeAPI setSkypeDelegate:self];
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center addObserver:self 
			   selector:@selector(handleNotification:) 
				   name:@"com.zer0gravitas.skypemanager" 
				 object:nil];
}

-(void)handleNotification:(NSNotification*) notification
{
	//	NSLog(@"got notification");
	
	NSDictionary *dict = [notification userInfo];
	NSNumber *stateStr =  [dict objectForKey:@"state"];
	state = [stateStr intValue];
	[self applyCurrentState];
}



-(void) applyCurrentState
{
	if ([SkypeAPI isSkypeRunning] && [SkypeAPI isSkypeAvailable])
	{
		[SkypeAPI connect];
		
	}
}



/*
 This method is called after Skype API client application has called connect.
 aAttachResponseCode is 0 on failure and 1 on success.
 */
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode
{
	//NSLog(@"got skype response code %d", aAttachResponseCode);
	//	if (aAttachResponseCode == YES){
	NSString *statusStr = [SkypeState stateToString:state];
	NSString *cmdStr = [[NSString alloc]initWithFormat:@"%@ %@",@"SET USERSTATUS", statusStr ];
	NSString *res = [SkypeAPI sendSkypeCommand: cmdStr];
	//NSLog(@"sendSkypeCommand [%@] result = [%@]", cmdStr, res);
	//	}
}


/*
 This method is called after Skype has been launched.
 */
- (void)skypeBecameAvailable:(NSNotification*)aNotification;
{
	[self applyCurrentState];
}

/*
 This method is called after Skype has been shutdown.
 */
- (void)skypeBecameUnavailable:(NSNotification*)aNotification;
{
}


- (void)skypeNotificationReceived:(NSString*)aNotificationString
{
	//NSLog(@"skypeNotificationReceived: %@", aNotificationString);
}


@end
