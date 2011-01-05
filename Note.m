//
//  Note.m
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
@end
