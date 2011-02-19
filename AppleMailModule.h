//
//  AppleMailModule.h
//  WorkPlayAway
//
//  Created by Charles on 2/16/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
#import "BaseInstance.h"

@interface AppleMailModule : BaseInstance <Reporter> {
	NSString *accountName;
	NSString *mailMailboxName;
	NSMutableArray *unreadMail;
	<AlertHandler> alertHandler;
	NSTextField *accountField;
	NSTextField *mailboxField;
	NSTextField *refreshIntervalField;
	NSStepper *refreshIntervalStepper;
	NSTextField *displayWindowField;
	NSStepper *displayWindowStepper;
	NSButton *useDisplayWindowButton;
	BOOL useDisplayWindow;
	NSTimeInterval displayWindow;
}
@property (nonatomic,retain) NSString *accountName;
@property (nonatomic,retain) NSString *mailMailboxName;
@property (nonatomic,retain) NSMutableArray *unreadMail;
@property (nonatomic,retain) <AlertHandler> alertHandler;
@property (nonatomic,retain) IBOutlet NSTextField *accountField;
@property (nonatomic,retain) IBOutlet NSTextField *mailboxField;
@property (nonatomic,retain) IBOutlet NSTextField *refreshIntervalField;
@property (nonatomic,retain) IBOutlet NSTextField *displayWindowField;
@property (nonatomic,retain) IBOutlet NSStepper *refreshIntervalStepper;
@property (nonatomic,retain) IBOutlet NSStepper *displayWindowStepper;
@property (nonatomic,retain) IBOutlet NSButton *useDisplayWindowButton;
@property (nonatomic)  NSTimeInterval displayWindow;
@property (nonatomic)  BOOL useDisplayWindow;

- (void) getUnread: (NSObject*) param;
- (void) fetchDone: (NSNotification*) msg;

@end
