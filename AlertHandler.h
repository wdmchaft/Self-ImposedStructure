//
//  AlertHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WPAAlert.h"


@protocol AlertHandler

-(void) handleAlert: (WPAAlert*) alert;

-(void) handleError: (WPAAlert*) error;

@end
