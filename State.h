//
//  State.h
//  Nudge
//
//  Created by Charles on 12/10/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol State

typedef enum {
	WPASTATE_FREE = 0, WPASTATE_AWAY = 1, WPASTATE_THINKING = 2, WPASTATE_THINKTIME=3, 
	WPASTATE_OFF = 4, WPASTATE_SUMMARY = 5, WPASTATE_VACATION = 6, WPASTATE_DONE = 7
}WPAStateType;

@end



