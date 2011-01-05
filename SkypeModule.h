//
//  SkypeModule.h
//  Nudge
//
//  Created by Charles on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseModule.h"
typedef enum {
	STATE_THINKING, STATE_AWAY, STATE_RUNNING,
} StateType;

typedef enum {
	SEQ_START, SEQ_RESP1, SEQ_RESP2,
} SequenceState;

@interface SkypeModule : BaseModule{
	StateType state;
	NSString *clientApplicationName;
	SequenceState sequenceState;
	NSDistributedNotificationCenter *center;
}
@property (nonatomic) StateType state;
@property (nonatomic) SequenceState sequenceState;
@property (nonatomic, retain) NSString* clientApplicationName;
@property (nonatomic, retain) NSDistributedNotificationCenter *center;

- (void) cancelSequence;
-(void) sendMsg;
@end
