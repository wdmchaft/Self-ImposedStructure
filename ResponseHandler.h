//
//  ResponseHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/30/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMProtocol.h"

@protocol ResponseHandler <NSObject>
- (id) initWithContext:(RTMProtocol*) ctx delegate: (NSObject* ) target selector: (SEL) callback ;

- (void) doParse: (NSData*) respStr;
- (void) handleResponse: (NSData*) respStr;
- (void) doCallback;

@end
