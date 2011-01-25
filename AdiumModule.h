//
//  AdiumModule.h
//  AdiumModule
//
//  Created by Charles on 12/8/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseInstance.h"
#import "AdiumState.h"

#define WORKSTATE @"WorkState"
#define PLAYSTATE @"PlayState"
#define AWAYSTATE @"AwayState"

typedef enum {
		STATE_THINKING, STATE_AWAY, STATE_FREE,
	} StateType;

@interface AdiumModule : BaseInstance{
		StateType state;
		NSPopUpButton *workStatusButton;
		NSPopUpButton *awayStatusButton;
		NSPopUpButton *playStatusButton;
		AdiumStateType adiumWorkState;
		AdiumStateType adiumPlayState;
		AdiumStateType adiumAwayState;
}
@property (nonatomic) StateType state;
@property (nonatomic, retain) IBOutlet NSPopUpButton *workStatusButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton *playStatusButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton *awayStatusButton;
@property (nonatomic) AdiumStateType adiumWorkState;
@property (nonatomic) AdiumStateType adiumPlayState;
@property (nonatomic) AdiumStateType adiumAwayState;

- (IBAction) workStatusChanged: (id) sender;
- (IBAction) playStatusChanged: (id) sender;
- (IBAction) awayStatusChanged: (id) sender;
- (AdiumStateType) stateFromIndex: (int) idx;
- (int) indexFromState: (AdiumStateType) state;

@end
