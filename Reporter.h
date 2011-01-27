//
//  Reporter.h
//  WorkPlayAway
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol Reporter <Instance>
@required
// implement these two to provide status information (email/events/tasks)
- (void) refresh: (<AlertHandler>) handler;
- (void) handleClick: (NSDictionary*) params;
@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, retain) NSString* notificationTitle;
@property (nonatomic) NSTimeInterval refreshInterval;
@end
