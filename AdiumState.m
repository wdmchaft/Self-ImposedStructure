//
//  AdiumState.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/17/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//
#import "AdiumState.h"
#import "Adium.h"

@implementation AdiumState
+ (NSString*) stateToString: (AdiumStateType) state
{
	NSString *ret = nil;
	switch (state) {
		case ADIUM_STATE_AWAY:
			ret = @"AWAY";
			break;
		case ADIUM_STATE_ONLINE:
			ret = @"AVAILABLE";
			break;
		case ADIUM_STATE_INVISIBLE:
			ret = @"INVISIBLE";
			break;
			//	case ADIUM_STATE_NA:
			//			ret = @"NA";
			//			break;
		default:
			break;
	}
	return ret;
}

@end
