//
//  AlertHandler.h
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"


@protocol AlertHandler

-(void) handleAlert: (Note*) alert;

-(void) handleError: (Note*) error;

@end
