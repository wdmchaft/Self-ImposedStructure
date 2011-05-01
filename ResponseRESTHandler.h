//
//  ResponseRESTHandler.h
//  CocoaTest
//
//  Created by Charles on 10/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMProtocol.h"
#import "ResponseHandler.h"

@interface ResponseRESTHandler : NSObject <ResponseHandler> {
	NSMutableData *respBuffer;
	RTMProtocol *context;
	NSMutableDictionary *currentDict;
	NSObject *target;
	SEL callback;
}
@property (nonatomic, retain) RTMProtocol* context;
@property (nonatomic, retain) NSMutableDictionary* currentDict;
@property (nonatomic, retain) NSMutableData * respBuffer;
@property (nonatomic, retain) NSObject * target;
@property (nonatomic) SEL callback;

- (id) initWithContext:(RTMProtocol*) ctx delegate: (NSObject*) target selector: (SEL) callback ;

- (void) doParse: (NSData*) respStr;
- (void) handleResponse: (NSData*) respStr;
- (void) doCallback;

@end
