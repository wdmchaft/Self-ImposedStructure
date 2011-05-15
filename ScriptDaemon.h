//
//  ScriptDaemon.h
//  WorkPlayAway
//
//  Created by Charles on 5/9/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppleScriptEventHandler.h"

@interface ScriptDaemon : NSObject {
	NSMutableDictionary *sessionMap;
	BOOL stopMe;
//	<AppleScriptEventHandler> aseHandler;
    NSDictionary *handlerMap;
	NSString *queueName;
}

@property (nonatomic, retain) NSMutableDictionary *sessionMap;
@property (nonatomic) BOOL stopMe;
@property (nonatomic, retain) NSDictionary *handlerMap;
@property (nonatomic, retain) NSString* queueName;

- (id) initWithName: (NSString*) name;
- (void) loop: (NSAutoreleasePool*) pool;
@end
