//
//  AdiumModule.m
//  AdiumModule
//
//  Created by Charles on 12/8/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "AdiumModule.h"
#import "Adium.h"


@implementation AdiumModule

-(void) start
{
}

-(void) think
{
	[super think];
	AdiumApplication *addiumApp = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];
	
	NSArray *array = [addiumApp statuses];
	for (AdiumStatus *stat in array){
		if (stat.statusType == AdiumStatusTypesInvisible){
		[addiumApp setGlobalStatus:stat];
		}
	}

}

-(void) putter
{
	[super putter];
	AdiumApplication *addiumApp = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];

	NSArray *array = [addiumApp statuses];
	for (AdiumStatus *stat in array){
		if ([stat.title isEqualToString:@"Available"]){
			[addiumApp setGlobalStatus:stat];
		}
	}

}

-(void) goAway
{
	[super goAway];
	AdiumApplication *addiumApp = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];

	NSArray *array = [addiumApp statuses];
	for (AdiumStatus *stat in array){
		if (stat.statusType == AdiumStatusTypesAway){
			[addiumApp setGlobalStatus:stat];
		}
	}
//	NSLog(@"status is %@", addiumApp.globalStatus.title);
}

-(void) startValidation: (NSObject*) callback  
{
	[super startValidation:callback];
	[super.validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	
}
@end
