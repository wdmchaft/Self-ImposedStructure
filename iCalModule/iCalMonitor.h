//
//  iCalMonitor.h
//  WorkPlayAway
//
//  Created by Charles on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 
* this is a gatekeeper for iCal applescripts -- its not safe to run these at the same time
*/

@interface iCalMonitor : NSObject {
@private
    BOOL stopMe;
    BOOL busy;
    NSAppleEventDescriptor *eventRes;
    NSDictionary *errorRes;
    NSMutableArray *scriptQueue;
    NSMutableArray *callbackQueue;
}

@property (nonatomic) BOOL stopMe;
@property (nonatomic) BOOL busy;
@property (nonatomic,retain) NSAppleEventDescriptor *eventRes;
@property (nonatomic,retain) NSDictionary *errorRes;
@property (nonatomic,retain) NSMutableArray *scriptQueue;
@property (nonatomic,retain) NSMutableArray *callbackQueue;

+(iCalMonitor*) iCalShared;
- (void) sendScript: (NSString*) script withCallback: (NSString*) callback;
- (void) sendDone;
@end
