//
//  SkypeState.h
//  SkypeMonitor
//
//  Created by Charles on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	SKYPE_STATE_AWAY, SKYPE_STATE_DND, SKYPE_STATE_INVISIBLE, SKYPE_STATE_ONLINE, SKYPE_STATE_INVALID
} SkypeStateType;


@interface SkypeState : NSObject {
}
+ (NSString*) stateToString: (SkypeStateType) state;

@end
