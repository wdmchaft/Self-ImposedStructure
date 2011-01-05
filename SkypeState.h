//
//  SkypeState.h
//  Nudge
//
//  Created by Charles on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	STATE_THINKING, STATE_AWAY, STATE_RUNNING,
} StateType;

typedef enum {
	SEQ_START, SEQ_RESP1, SEQ_RESP2,
} SequenceState;

@protocol SkypeState


@end
