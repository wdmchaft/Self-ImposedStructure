//
//  SkypeManagerDelegate.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/15/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SkypeAPI.h"
#import "SkypeState.h"

@interface SkypeManagerDelegate : NSObject <NSApplicationDelegate, SkypeAPIDelegate> {
	NSWindow *window;
	SkypeStateType state;
	NSString *clientApplicationName;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) SkypeStateType state;
@property (nonatomic, retain) NSString *clientApplicationName;
-(void) applyCurrentState;
-(void)handleNotification:(NSNotification*) notification;

@end
