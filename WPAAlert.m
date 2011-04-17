//
//  Note.m
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "WPAAlert.h"


@implementation WPAAlert
@synthesize moduleName;
@synthesize urgent;
@synthesize title;
@synthesize message;
@synthesize params;
@synthesize sticky;
@synthesize clickable;
@synthesize lastAlert;
@synthesize isWork;

-(id) copyWithZone: (NSZone *) zone
{
	WPAAlert *copy = [[[self class] allocWithZone: zone] init];
					
    [copy setModuleName:[self moduleName]];
    [copy setUrgent:[self urgent]];
    [copy setSticky:[self sticky]];
    [copy setIsWork:[self isWork]];
    [copy setTitle:[self title]];
    [copy setMessage:[self message]];
    [copy setParams:[self params]];
	[copy setClickable: [self clickable]];
	[copy setLastAlert: [self lastAlert]];
    return copy;
}

- (BOOL) isEqual:(id) object
{
	if (![[object class] isEqual:[self class]])
		return NO;
	WPAAlert *other = (WPAAlert*) object;
	if (![moduleName isEqualToString:other.moduleName]){
	//	NSLog(@"moduleName %@ != %@", moduleName, other.moduleName);
		return NO;
	}
	if (![title isEqualToString:other.title]){
	//	NSLog(@"title %@ != %@", title, other.title);
		return NO;
	}
	if (![message isEqualToString:other.message]){
	//	NSLog(@"message %@ != %@", message, other.message);
		return NO;
	} else {
	//	NSLog(@"%@ == %@", message, other.message);
	}
	return YES;
}
@end
