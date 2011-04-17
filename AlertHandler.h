//
//  AlertHandler.h
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WPAAlert.h"


@protocol AlertHandler

-(void) handleAlert: (WPAAlert*) alert;

-(void) handleError: (WPAAlert*) error;

@end
