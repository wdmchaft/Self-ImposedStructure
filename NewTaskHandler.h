//
//  NewTaskHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/30/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimelineHandler.h"


@interface NewTaskHandler : TimelineHandler {
	NSDictionary *dictionary;

}
@property (nonatomic, retain) NSDictionary *dictionary;
- (void) timelineRequest;
- (void) start;
@end
