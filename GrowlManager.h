//
//  GrowlDelegate.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "Growl.h"
#import "AlertHandler.h"
#import "Instance.h"
#import "Stateful.h"

@interface GrowlManager : NSObject <GrowlApplicationBridgeDelegate, AlertHandler, Stateful> {
	NSMutableArray *savedQ;
	NSMutableArray *alertQ;
	NSTimer	 *timer;
}
@property (nonatomic,retain) NSMutableArray *savedQ;
@property (nonatomic,retain) NSMutableArray *alertQ;
@property (nonatomic,retain) NSTimer *timer;

-(void) growlAlert: (WPAAlert*) alert;
- (void) growlThis: (NSString*) this isSticky: (BOOL) sticky withTitle: (NSString*) title;
- (void) growlFYI: (NSString*) this;
- (void) growlNotificationWasClicked:(id)ctx;
- (void) growlLoop:(NSTimer *)timeIn;
- (void) stop;
- (void) changeState:(WPAStateType)newState;
- (void) workState;
- (void) freeState;
- (void) awayState;
- (void) clearQueues;
@end
