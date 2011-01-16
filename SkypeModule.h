//
//  SkypeModule.h
//  Nudge
//
//  Created by Charles on 12/19/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseModule.h"
#import "SkypeState.h"

#define WORKSTATE @"WorkState"
#define PLAYSTATE @"PlayState"
#define AWAYSTATE @"AwayState"

#define SKYPEMONITOR @"SkypeManager"

typedef enum {
	STATE_THINKING, STATE_AWAY, STATE_RUNNING,
} StateType;


@interface SkypeModule : BaseModule {
	StateType state;
	NSString *clientApplicationName;
	NSDistributedNotificationCenter *center;
	NSPopUpButton *workStatusButton;
	NSPopUpButton *awayStatusButton;
	NSPopUpButton *playStatusButton;
	SkypeStateType skypeWorkState;
	SkypeStateType skypePlayState;
	SkypeStateType skypeAwayState;
	NSTask *monitorTask;
}
@property (nonatomic) StateType state;
@property (nonatomic, retain) NSString* clientApplicationName;
@property (nonatomic, retain) NSDistributedNotificationCenter *center;
@property (nonatomic, retain) IBOutlet NSPopUpButton *workStatusButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton *playStatusButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton *awayStatusButton;
@property (nonatomic) SkypeStateType skypeWorkState;
@property (nonatomic) SkypeStateType skypePlayState;
@property (nonatomic) SkypeStateType skypeAwayState;
@property (nonatomic, retain) NSTask *monitorTask;
-(void) sendMsg;
- (IBAction) workStatusChanged: (id) sender;
- (IBAction) playStatusChanged: (id) sender;
- (IBAction) awayStatusChanged: (id) sender;
-(SkypeStateType) wpaStateToSkypeState: (StateType) wpaState;
@end
