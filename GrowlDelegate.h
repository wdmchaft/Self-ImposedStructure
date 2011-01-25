//
//  GrowlDelegate.h
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "Growl.h"
#import "AlertHandler.h"

@interface GrowlDelegate : NSObject <GrowlApplicationBridgeDelegate, AlertHandler> {
	NSMutableArray *savedQ;
	NSMutableArray *alertQ;
	NSTimer	 *timer;
}
@property (nonatomic,retain) NSMutableArray *savedQ;
@property (nonatomic,retain) NSMutableArray *alertQ;
@property (nonatomic,retain) NSTimer *timer;

-(void) growlAlert: (Note*) alert;
- (void) growlNotificationWasClicked:(id)ctx;
@end
