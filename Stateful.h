//
//  Stateful.h
//  WorkPlayAway
//
//  Created by Charles on 1/26/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol Stateful <Instance>

- (void) changeState:(WPAStateType) newState;

@end
