//
//  WPABridge.m
//  WorkPlayAway
//
//  Created by Charles on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WPABridge.h"
#import "Queues.h"


@implementation WPABridge

- (id)initWithQueueName: (NSString*) queueName
{
    self = [super init];
    if (self) {
        _baseQueueName = queueName;
    }
    
    return self;
}
- (void) sendUpdated:(NSString *)moduleName
{
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	NSString *updateQueue = [Queues queueNameFor:WPA_UPDATEQUEUE fromBase:_baseQueueName];
	[center postNotificationName: updateQueue 
						  object: nil 
						userInfo: [NSDictionary dictionaryWithObject:moduleName forKey:@"module"]];

}
- (void) raiseError: (NSDictionary*) errorInfo {};
- (void) sendActivity: (NSDictionary*) activity{};
- (void) sendComplete: (NSDictionary*) complete{};
@end
