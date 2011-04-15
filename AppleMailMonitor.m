//
//  AppleMailMonitor.m
//  WorkPlayAway
//
//  Created by Charles on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppleMailMonitor.h"


@implementation AppleMailMonitor

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setPrefix:@"mail"];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+(AppleMailMonitor*) appleMailShared
{
    if (!appleMailShared){
        appleMailShared = [AppleMailMonitor new];
        [appleMailShared startLoop];
    }
    return appleMailShared;
}
@end
