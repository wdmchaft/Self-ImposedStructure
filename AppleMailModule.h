//
//  AppleMailModule.h
//  WorkPlayAway
//
//  Created by Charles on 2/16/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
#import "BaseReporter.h"

@interface AppleMailModule : BaseReporter {
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
	NSDate *lastCheck;
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
@property (nonatomic,retain) NSDate *lastCheck;

- (void) getUnread: (NSObject*) param;
- (void) fetchDone: (NSNotification*) msg;
- (IBAction) clickUseDisplayWindow: (id) sender;
- (void) validateDone: (NSNotification*) note;
- (void) doValidate: (NSObject*) params;


@end
