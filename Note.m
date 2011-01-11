//
//  Note.m
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "Note.h"


@implementation Note
@synthesize moduleName;
@synthesize urgent;
@synthesize title;
@synthesize message;
@synthesize params;
@synthesize sticky;

-(id) copyWithZone: (NSZone *) zone
{
	Note *copy = [[[self class] allocWithZone: zone] init];
					
    [copy setModuleName:[self moduleName]];
    [copy setUrgent:[self urgent]];
    [copy setSticky:[self sticky]];
    [copy setTitle:[self title]];
    [copy setMessage:[self message]];
    [copy setParams:[self params]];
	
    return copy;
}

- (BOOL) isEqual:(id) object
{
	if (![[object class] isEqual:[self class]])
		return NO;
	Note *other = (Note*) object;
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
