//
//  CompleteProcessHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/25/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimelineHandler.h"

@interface CompleteProcessHandler : TimelineHandler {
	NSDictionary *dictionary;
}
@property (nonatomic,retain) NSDictionary *dictionary;
//@property (nonatomic, retain) id<RTMCallback> callback;

- (void) timelineRequest;
- (void) start;

@end
