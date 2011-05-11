//
//  AppleScriptEventHandler
//  WorkPlayAway
//
//  Created by Charles on 5/9/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol AppleScriptEventHandler
- (void) handleEventDescriptor: (NSAppleEventDescriptor*) aDescriptor list: (NSMutableArray*) newestMail;


@end
