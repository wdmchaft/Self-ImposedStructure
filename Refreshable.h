//
//  Refreshable.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol Refreshable

-(void) refresh:(<AlertHandler>) handler;
@property (nonatomic) NSTimeInterval refreshInterval;
@end
