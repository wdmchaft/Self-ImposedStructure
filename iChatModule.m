//
//  iChatModule.m
//  Nudge
//
//  Created by Charles on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iChatModule.h"


@implementation iChatModule

-(void) start
{
}

-(void) think
{
	[super think];
	iChatApplication *iChatApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iChat"];
	NSArray *services = [iChatApp services];
	for (iChatService *service in services)
	{
		service.status = iChatMyStatusInvisible;
	}
	
}

-(void) putter
{

	[super think];
	iChatApplication *iChatApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iChat"];
	NSArray *services = [iChatApp services];
	for (iChatService *service in services)
	{
		service.status = iChatMyStatusAvailable;
	}
	
}

-(void) goAway
{

	[super think];
	iChatApplication *iChatApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iChat"];
	NSArray *services = [iChatApp services];
	for (iChatService *service in services)
	{
		service.status = iChatMyStatusAway;
	}
	
}

-(void) startValidation: (NSObject*) callback  
{
	[super startValidation:callback];
	[super.validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	
}

@end
