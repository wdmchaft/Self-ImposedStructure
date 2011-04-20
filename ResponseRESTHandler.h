//
//  ResponseRESTHandler.h
//  CocoaTest
//
//  Created by Charles on 10/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMCallback.h"
#import "RTMModule.h"

@interface ResponseRESTHandler : NSObject {
	NSMutableData *respBuffer;
	RTMModule *context;
	id<RTMCallback> callback;
	NSMutableDictionary *currentDict;
	NSString *listId;
}
@property (nonatomic, retain) RTMModule* context;
@property (nonatomic, retain) NSMutableDictionary* currentDict;
@property (nonatomic, retain) id<RTMCallback> callback;
@property (nonatomic, retain) NSMutableData * respBuffer;
@property (nonatomic, retain) NSString * listId;
- (ResponseRESTHandler*) initWithContext:(RTMModule*) ctx andDelegate: (id<NSObject>) delegate;

- (void) doParse: (NSData*) respStr;
-(void) handleResponse: (NSData*) respStr;
- (void) doCallback;

@end
