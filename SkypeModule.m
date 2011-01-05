//
//  SkypeModule.m
//  Nudge
//
//  Created by Charles on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkypeModule.h"

@implementation SkypeModule
@synthesize state;
@synthesize sequenceState;
@synthesize clientApplicationName;
@synthesize center;

-(SkypeModule*) initWithNibName: (NSString*) nibName 
			   bundle: (NSBundle*) bundle {
	self = [super initWithNibName: nibName
						   bundle: bundle];
	if (self != nil)
	{
		 center = [NSDistributedNotificationCenter defaultCenter];
	}
	return self;
}

-(void) start
{
}
-(void) cancelSequence
{
}

-(void) think
{
	[super think];
	state = STATE_THINKING;
	[self sendMsg];
}

- (void) sendMsg
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state], @"state",nil ];
	NSNotification *msg = [NSNotification notificationWithName:@"org.ottoject.nudge.SkypeMonitor" 
														object:[[self class]description]
													  userInfo:dict]; 
	[center postNotification: msg];
}
-(void) putter
{
	[super putter];
	state = STATE_RUNNING;	
	[self sendMsg];
}

-(void) goAway
{
	[super goAway];
	state = STATE_AWAY;	
	[self sendMsg];
}

-(void) startValidation: (NSObject*) callback  
{
	[super startValidation:callback];
	[super.validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	
}

@end