
//
//  AdiumModule.m
//  AdiumModule
//
//  Created by Charles on 12/8/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "AdiumModule.h"
#import "Adium.h"
#import "State.h"

@implementation AdiumModule
@synthesize state;
@synthesize adiumWorkState;
@synthesize adiumPlayState;
@synthesize adiumAwayState;
@synthesize workStatusButton;
@synthesize playStatusButton;
@synthesize awayStatusButton;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;

-(void) changeState: (WPAStateType) newState
{
	NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.adiumX.adiumX"];
    if (apps && [apps count] > 0) {
        AdiumStatusTypes newStatus;
        switch (newState) {
            case WPASTATE_THINKING:
                newStatus = adiumWorkState;
                break;
            case WPASTATE_AWAY:
                newStatus = adiumAwayState;
                break;
            case WPASTATE_FREE:
                newStatus = adiumPlayState;
                break;
            default:
                break;
        }
        AdiumApplication *addiumApp = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];
        
        NSArray *array = [addiumApp statuses];
        for (AdiumStatus *stat in array){
            if (stat.statusType == newStatus){
                [addiumApp setGlobalStatus:stat];
            }
        }
    }
}

-(void) startValidation: (NSObject*) callback  
{
	[super startValidation:callback];
	[validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	
}

- (IBAction) workStatusChanged: (id) sender{
	adiumWorkState = [self stateFromIndex:[workStatusButton indexOfItem:[workStatusButton selectedItem]]];
}

- (IBAction) playStatusChanged: (id) sender {
	adiumPlayState = [self stateFromIndex:[playStatusButton indexOfItem:[playStatusButton selectedItem]]];
}

- (IBAction) awayStatusChanged: (id) sender{
	adiumAwayState = [self stateFromIndex:[awayStatusButton indexOfItem:[awayStatusButton selectedItem]]];
}

- (AdiumStateType) stateFromIndex: (int) idx
{
	switch(idx){
		case 0:
			return ADIUM_STATE_AWAY;
			break;
		case 1:
			return ADIUM_STATE_INVISIBLE;
			break;
		case 2:
			return ADIUM_STATE_ONLINE;
			break;
	}
	return -1;
}

- (int) indexFromState: (AdiumStateType) stat 
{
	switch(stat){
		case ADIUM_STATE_AWAY:
			return 0;
			break;
		case ADIUM_STATE_INVISIBLE:
			return 1;
			break;
		case ADIUM_STATE_ONLINE:
			return 2;
			break;
	}
	return -1;
}

-(void) loadView
{
	[super loadView];
	[playStatusButton selectItemAtIndex:[self indexFromState:adiumPlayState]];
	[awayStatusButton selectItemAtIndex:[self indexFromState:adiumAwayState]];
	[workStatusButton selectItemAtIndex:[self indexFromState:adiumWorkState]];
}

-(void) loadDefaults
{
	[super loadDefaults];
	NSNumber *temp =  [super loadDefaultForKey:WORKSTATE];
	adiumWorkState = (temp == nil)? ADIUM_STATE_INVISIBLE :[temp intValue];
	temp =  [super loadDefaultForKey:AWAYSTATE];
	adiumAwayState = (temp == nil)? ADIUM_STATE_AWAY :[temp intValue];
	temp =  [super loadDefaultForKey:PLAYSTATE];
	adiumPlayState = (temp == nil)? ADIUM_STATE_ONLINE :[temp intValue];
	
}


-(void) clearDefaults
{
	[super clearDefaults];
	[super clearDefaultValue:[NSNumber numberWithInt:adiumPlayState] forKey:PLAYSTATE];
	[super clearDefaultValue:[NSNumber numberWithInt:adiumAwayState] forKey:AWAYSTATE];
	[super clearDefaultValue:[NSNumber numberWithInt:adiumWorkState] forKey:WORKSTATE];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) saveDefaults
{
	[super saveDefaults];
	[super saveDefaultValue:[NSNumber numberWithInt:adiumPlayState] forKey:PLAYSTATE];
	[super saveDefaultValue:[NSNumber numberWithInt:adiumAwayState] forKey:AWAYSTATE];
	[super saveDefaultValue:[NSNumber numberWithInt:adiumWorkState] forKey:WORKSTATE];
	[[NSUserDefaults standardUserDefaults] synchronize];		
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil params: appParams{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil params:appParams];
	if (self){
		adiumPlayState = ADIUM_STATE_ONLINE;
		adiumWorkState = ADIUM_STATE_INVISIBLE;
		adiumAwayState = ADIUM_STATE_AWAY;
	}
	return self;
}
@end
