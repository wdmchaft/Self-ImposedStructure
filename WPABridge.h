//
//  WPABridge.h
//  WorkPlayAway
//
//  Created by Charles on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPABridge : NSObject {
    @private
    NSString *_baseQueueName;
}

- (id) initWithQueueName: (NSString*) queueName;
- (void) raiseError: (NSDictionary*) errorInfo;
- (void) sendActivity: (NSDictionary*) activity;
- (void) sendComplete: (NSDictionary*) complete;
- (void) sendUpdated: (NSString*) moduleName;

@end
