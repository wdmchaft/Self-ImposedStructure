//
//  CompleteProcessHandler.h
//  WorkPlayAway
//
//  Created by Charles on 1/25/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMModule.h"
#import "TimelineHandler.h"

@interface CompleteProcessHandler : TimelineHandler <RTMCallback> {
    NSDictionary *dictionary;
	TimelineHandler *tlHandler;
	NSString *token;
//	id<RTMCallback> *callback;
}
@property (nonatomic,retain) NSDictionary *dictionary;
@property (nonatomic, retain) TimelineHandler *tlHandler;
@property (nonatomic, retain) NSString *token;
//@property (nonatomic, retain) id<RTMCallback> callback;

- (void) timelineRequest;
- (void) start;
- (void) sendComplete;
- (id) initWithDictionary:(NSDictionary*) ctx token: tokenStr andDelegate: (NSObject*) delegate;

@end
