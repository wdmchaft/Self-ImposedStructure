//
//  RefreshManager.h
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlertHandler.h"
#import "Growl.h"


@interface RefreshManager : NSObject {
	NSArray *timers;
	<AlertHandler> alertHandler;
	BOOL running;
}
@property (nonatomic,retain) NSArray *timers;
@property (nonatomic,retain) <AlertHandler> alertHandler;
@property (nonatomic) BOOL running;

- (id) initWithHandler:(<AlertHandler>) handler;
- (void) startWithRefresh: (BOOL) doRefresh;
- (void) doRefresh: (NSTimer*) timer;

- (void)stop;
@end
