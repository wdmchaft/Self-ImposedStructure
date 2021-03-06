//
//  RTMModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"
#import "TaskList.h"
#import "RTMProtocol.h"
#import "BaseTaskList.h"

@interface RTMModule : BaseTaskList {
	NSTextField *userText;
	NSSecureTextField *passwordText;
	NSTextField *refreshText;
	NSPopUpButton *listsCombo;
	NSTextField *comboLabel;
	NSTextField *stepperLabel;
	NSTextField *refreshLabel;
	NSTextField *lookAheadLabel;
	NSTextField *lookAheadNote;
	NSButton *authButton;
	NSProgressIndicator *progInd;	
	NSMutableDictionary *alarmSet;
	id<AlertHandler> handler;
	NSString *lastError;
    NSButton *isWorkButton;
    NSButton *isTrackedButton;
	NSTimeInterval lookAheadWindow;
	NSTextField *lookAheadText;
	RTMProtocol *protocol;
	BOOL summaryMode;
	NSPopUpButton *projectPopup;
	NSTextField *projectLabel;
}

//@property (nonatomic, retain) NSMutableArray *tasksList;
@property (nonatomic, retain) IBOutlet NSTextField *userText;
@property (nonatomic, retain) IBOutlet NSTextField *refreshText;
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadText;
@property (nonatomic, retain) IBOutlet NSSecureTextField *passwordText;
@property (nonatomic, retain) IBOutlet NSPopUpButton *listsCombo;
@property (nonatomic, retain) IBOutlet NSTextField *comboLabel;
@property (nonatomic, retain) IBOutlet NSTextField *stepperLabel;
@property (nonatomic, retain) IBOutlet NSTextField *refreshLabel;
@property (nonatomic, retain) IBOutlet NSTextField *projectLabel;
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadLabel;
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadNote;
@property (nonatomic, retain) IBOutlet NSPopUpButton *projectPopup;
@property (nonatomic, retain) IBOutlet NSButton *authButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progInd;
@property (nonatomic, retain) NSMutableDictionary *alarmSet;
@property (nonatomic, retain) id<AlertHandler> handler;
@property (nonatomic, retain) NSString *lastError;
@property (nonatomic, retain) NSString *completeQueue;
@property (nonatomic, retain) IBOutlet NSButton *isWorkButton;
@property (nonatomic, retain) IBOutlet NSButton *isTrackedButton;
@property (nonatomic) NSTimeInterval lookAheadWindow;
@property (nonatomic,retain) RTMProtocol *protocol;
@property (nonatomic) BOOL summaryMode;

- (IBAction) clickAuthButton: (id) sender;
- (void) clickAuthorizedButton: (id) sender;
- (IBAction) clickList: (id) sender;
- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) stop;
- (void) handleRTMError:(NSDictionary*) errInfo;
- (NSDictionary*) idMapping;
@end
