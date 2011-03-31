//
//  SVRefHandler.m
//  WorkPlayAway
//
//  Created by Charles on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVRefHandler.h"


@implementation SVRefHandler
@synthesize data, ref;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) handleError: (Note*) error
{
    [ref endRefresh];
}	

- (void) handleAlert: (Note*) alert
{
	if (alert.lastAlert){
        [ref endRefresh];
	}
	else {
		if (!data){
			data = [NSMutableArray new];
		}
		[data addObject: alert.params];
	}
}

@end

