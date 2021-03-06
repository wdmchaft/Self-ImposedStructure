//
//  SVRefHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/30/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
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

-(void) handleError: (WPAAlert*) error
{
    [ref endRefresh];
}	

- (void) handleAlert: (WPAAlert*) alert
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

