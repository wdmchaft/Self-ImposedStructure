//
//  WPAMDelegate.h
//  WorkPlayAway
//
//  Created by Charles on 4/12/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"

@protocol WPAMDelegate
-(void) changeState:WPAStateType;
-(void) clickStart: (id) caller;


@end
