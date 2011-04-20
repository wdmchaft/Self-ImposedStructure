//
//  AppleMailMonitor.m
//  Self-Imposed Structure
//
//  Created by Charles on 4/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "AppleMailMonitor.h"


@implementation AppleMailMonitor
static AppleMailMonitor* _appleMailShared;

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
    if (!_appleMailShared){
        _appleMailShared = [AppleMailMonitor new];
        [_appleMailShared startLoop];
    }
    return _appleMailShared;
}
@end
