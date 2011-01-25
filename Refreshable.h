//
//  Refreshable.h
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol Refreshable

-(void) refresh:(<AlertHandler>) handler;
-(NSTimeInterval) refreshInterval;

@end
