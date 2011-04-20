//
//  RolloverDelegate.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/12/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol RolloverDelegate
- (void) gotRollover;
- (void) gotDone;

@end
