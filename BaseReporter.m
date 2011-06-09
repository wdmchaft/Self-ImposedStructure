//
//  BaseReporter.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "BaseReporter.h"


@implementation BaseReporter
@synthesize summaryTitle;
@synthesize isWorkRelated;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic name;
@dynamic category;

- (id) initWithNibName:(NSString *) nibNameOrNil 
				bundle:(NSBundle *) nibBundleOrNil
				params: (NSDictionary *) appParams
{
	return [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil params: appParams];
}

- (void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary useCache: (BOOL) cached {}
- (void) initSummaryTable: (NSTableView*) view{}
- (void) handleClick:(NSDictionary *)params{}

-(void) saveDefaults
{
	[self saveDefaultValue:[NSNumber numberWithInt:isWorkRelated] forKey:ISWORKRELATED];
	[self saveDefaultValue:summaryTitle forKey:SUMMARYTITLE];
	[super saveDefaults];
}

-(void) clearDefaults
{
	[self clearDefaultValue:nil forKey:ISWORKRELATED];
	[self clearDefaultValue:nil forKey:SUMMARYTITLE];
	[super clearDefaults];
}

-(void) loadDefaults{
	[super loadDefaults];
	NSNumber *temp = [self loadDefaultForKey:ISWORKRELATED];
	isWorkRelated = [temp intValue];
	summaryTitle = [self loadDefaultForKey:SUMMARYTITLE];
}
@end


