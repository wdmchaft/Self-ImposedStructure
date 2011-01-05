//
//  ResponseRESTHandler.h
//  CocoaTest
//
//  Created by Charles on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMCallback.h"
#import "RTMModule.h"

@interface ResponseRESTHandler : NSObject {
	NSMutableData *respBuffer;
	RTMModule *context;
	<RTMCallback> callback;
	NSMutableDictionary *currentDict;
	NSString *listId;
}
@property (nonatomic, retain) RTMModule* context;
@property (nonatomic, retain) NSMutableDictionary* currentDict;
@property (nonatomic, retain) <RTMCallback> callback;
@property (nonatomic, retain) NSMutableData * respBuffer;
@property (nonatomic, retain) NSString * listId;
- (ResponseRESTHandler*) initWithContext:(RTMModule*) ctx andDelegate: (NSObject*) delegate;

- (void) doParse: (NSData*) respStr;
-(void) handleResponse: (NSData*) respStr;
- (void) doCallback;

@end
