//
//  AppleMailMonitor.m
//  WorkPlayAway
//
//  Created by Charles on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iCalMonitor.h"


@implementation iCalMonitor
static iCalMonitor* _iCalShared;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setPrefix:@"iCal"];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+(iCalMonitor*) iCalShared
{
    if (!_iCalShared){
        _iCalShared = [iCalMonitor new];
        [_iCalShared startLoop];
    }
    return _iCalShared;
}
@end
