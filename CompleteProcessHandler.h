//
//  CompleteProcessHandler.h
//  WorkPlayAway
//
//  Created by Charles on 1/25/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMModule.h"
#import "TimelineHandler.h"

@interface CompleteProcessHandler : NSObject {
	NSDictionary *context;
	TimelineHandler *tlHandler;
	NSString *token;
	NSObject *callback;
}
@property (nonatomic,retain) NSDictionary *context;
@property (nonatomic, retain) TimelineHandler *tlHandler;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSObject *callback;

- (void) timelineRequest;
- (void) start;
- (void) sendComplete;
- (id) initWithContext:(NSDictionary*) ctx token: tokenStr andDelegate: (NSObject*) delegate;

@end
