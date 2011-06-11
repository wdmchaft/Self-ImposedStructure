//
//  Queues.h
//  Self-Imposed Structure
//
//  Created by Charles on 6/1/11.
//  Copyright 2011 zer0gravitas.com All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define WPA_STATEQUEUE @"changestate"
#define WPA_COMPLETEQUEUE @"completetask"
#define WPA_UPDATEQUEUE @"updatetask"

@interface Queues : NSObject {

}
+ (NSString*) queueNameFor: (NSString*) type fromBase: (NSString*) base;
@end
