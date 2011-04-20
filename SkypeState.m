//
//  SkypeState.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/15/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SkypeState.h"

@implementation SkypeState

+ (NSString*) stateToString: (SkypeStateType) state
{
	NSString *ret = nil;
	switch (state) {
		case SKYPE_STATE_AWAY:
			ret = @"AWAY";
			break;
		case SKYPE_STATE_DND:
			ret = @"DND";
			break;
		case SKYPE_STATE_ONLINE:
			ret = @"ONLINE";
			break;
		case SKYPE_STATE_INVISIBLE:
			ret = @"INVISIBLE";
			break;
	//	case SKYPE_STATE_NA:
//			ret = @"NA";
//			break;
		default:
			break;
	}
	return ret;
}

@end
