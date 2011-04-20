//
//  RefreshListHandler
//  Self-Imposed Structure
//
//  Created by Charles on 1/9/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "RefreshListHandler.h"


@implementation RefreshListHandler

- (id) initWithContext: (RTMModule*) ctx andDelegate: (id<RTMCallback>) delegate 
{
	self = (RefreshListHandler*)[super initWithContext:ctx andDelegate: delegate];
	
	return self;
}

- (void) doCallback
{
	[callback taskRefreshDone];
}
@end
