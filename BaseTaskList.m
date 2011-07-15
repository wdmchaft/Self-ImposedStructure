//
//  BaseTaskList.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "BaseTaskList.h"
#import "Queues.h"


@implementation BaseTaskList
@synthesize tracked;
@synthesize defaultProject;
@dynamic baseQueue;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic summaryTitle;
@dynamic isWorkRelated;
@dynamic enabled;
@dynamic name;
@dynamic category;
@dynamic params;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil params: _params
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil params:_params];
	if (self){
		defaultProject = @"Uncategorized";
	}
	return self;
}

- (id) init 
{
	self = [super init];
	if (self){
		defaultProject = @"Uncategorized";
	}
	return self;
}
-(void) saveDefaults{
	[self saveDefaultValue:[NSNumber numberWithInt:tracked] forKey:TRACKED];
	[self saveDefaultValue:defaultProject forKey:DEFAULTPROJECT];
	[super saveDefaults];
}

-(void) clearDefaults{
	[self clearDefaultValue:[NSNumber numberWithInt:tracked] forKey:TRACKED];
	[self clearDefaultValue:defaultProject forKey:DEFAULTPROJECT];
	[super clearDefaults];
}

-(void) loadDefaults{
	[super loadDefaults];
	NSNumber *temp = [self loadDefaultForKey:TRACKED];
	tracked = [temp intValue];
	defaultProject = [self loadDefaultForKey:DEFAULTPROJECT];
	if (defaultProject == nil)
		defaultProject = @"Uncategorized";
}

@end
