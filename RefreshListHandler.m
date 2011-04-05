//
//  RefreshListHandler
//  WorkPlayAway
//
//  Created by Charles on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
