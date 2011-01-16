//
//  SkypeModule.m
//  Nudge
//
//  Created by Charles on 12/19/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "SkypeModule.h"

@implementation SkypeModule
@synthesize state;
@synthesize clientApplicationName;
@synthesize center;
@synthesize skypeWorkState;
@synthesize skypePlayState;
@synthesize skypeAwayState;
@synthesize workStatusButton;
@synthesize playStatusButton;
@synthesize awayStatusButton;
@synthesize monitorTask;

-(SkypeModule*) initWithNibName: (NSString*) nibName 
			   bundle: (NSBundle*) bundle {
	self = [super initWithNibName: nibName
						   bundle: bundle];
	if (self != nil)
	{
		 center = [NSDistributedNotificationCenter defaultCenter];
		skypeAwayState = SKYPE_STATE_AWAY;
		skypePlayState = SKYPE_STATE_ONLINE;
		skypeWorkState = SKYPE_STATE_INVISIBLE;
	}
	return self;
}

-(void) start
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *monitorPath = [NSString stringWithFormat:@"%@/%@.app/Contents/MacOS/%@",@"/Applications/", 
							 SKYPEMONITOR,SKYPEMONITOR];
	NSLog(@"monitorPath = %@", monitorPath);
	NSError *errInfo;
	monitorTask = [NSTask launchedTaskWithLaunchPath:monitorPath arguments:[NSArray new]];
}

-(void) stop
{
	if (monitorTask)
		[monitorTask terminate];
}

-(void) think
{
	[super think];
	state = STATE_THINKING;
	[self sendMsg];
}

- (SkypeStateType) wpaStateToSkypeState: (StateType) wpaState
{
	switch (wpaState) {
		case STATE_RUNNING:
			return skypePlayState;
			break;
		case STATE_AWAY:
			return skypeAwayState;
			break;
		case STATE_THINKING:
			return skypeWorkState;
			break;
	}
	return	 SKYPE_STATE_INVALID;
}

- (void) sendMsg
{
	SkypeStateType skypeState = (SkypeStateType)[self wpaStateToSkypeState:state];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:skypeState], @"state",nil ];
	NSNotification *msg = [NSNotification notificationWithName:@"com.workplayaway.skypemanager" 
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

- (IBAction) workStatusChanged: (id) sender{
	skypeWorkState = [workStatusButton indexOfItem:[workStatusButton selectedItem]];
}

- (IBAction) playStatusChanged: (id) sender {
	skypePlayState = [playStatusButton indexOfItem:[playStatusButton selectedItem]];
}

- (IBAction) awayStatusChanged: (id) sender{
	skypeAwayState = [awayStatusButton indexOfItem:[awayStatusButton selectedItem]];
}

-(void) loadView
{
	[super loadView];
	[playStatusButton selectItemAtIndex:skypePlayState];
	[awayStatusButton selectItemAtIndex:skypeAwayState];
	[workStatusButton selectItemAtIndex:skypeWorkState];
}

-(void) loadDefaults
{
	[super loadDefaults];
	NSNumber *temp =  [super loadDefaultForKey:WORKSTATE];
	skypeWorkState = (temp == nil)? SKYPE_STATE_INVISIBLE :[temp intValue];
	temp =  [super loadDefaultForKey:AWAYSTATE];
	skypeAwayState = (temp == nil)? SKYPE_STATE_AWAY :[temp intValue];
	temp =  [super loadDefaultForKey:PLAYSTATE];
	skypePlayState = (temp == nil)? SKYPE_STATE_ONLINE :[temp intValue];

}


-(void) clearDefaults
{
	[super clearDefaults];
	[super clearDefaultValue:[NSNumber numberWithInt:skypePlayState] forKey:PLAYSTATE];
	[super clearDefaultValue:[NSNumber numberWithInt:skypeAwayState] forKey:AWAYSTATE];
	[super clearDefaultValue:[NSNumber numberWithInt:skypeWorkState] forKey:WORKSTATE];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) saveDefaults
{
	[super saveDefaults];
	[super saveDefaultValue:[NSNumber numberWithInt:skypePlayState] forKey:PLAYSTATE];
	[super saveDefaultValue:[NSNumber numberWithInt:skypeAwayState] forKey:AWAYSTATE];
	[super saveDefaultValue:[NSNumber numberWithInt:skypeWorkState] forKey:WORKSTATE];
	[[NSUserDefaults standardUserDefaults] synchronize];		
}

@end