//
//  iChatModule.m
//  Nudge
//
//  Created by Charles on 1/4/11.
//  Copyright 2011 workplayaway.com. All rights reserved.
//

#import "iChatModule.h"


@implementation iChatModule
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;

- (void) changeState: (WPAStateType) newState
{
	
	iChatMyStatus newStatus;
	switch (newState) {
		case WPASTATE_THINKING:
			newStatus = iChatMyStatusInvisible;
			break;
		case WPASTATE_AWAY:
			newStatus = iChatMyStatusAway;
			break;
		case WPASTATE_FREE:
			newStatus = iChatMyStatusAvailable;
			break;
		default:
			break;
	}
	iChatApplication *iChatApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iChat"];
	NSArray *services = [iChatApp services];
	for (iChatService *service in services)
	{
		service.status = newStatus;
	}
}

-(void) startValidation: (NSObject*) callback  
{
	[super startValidation:callback];
	[validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	
}

@end
