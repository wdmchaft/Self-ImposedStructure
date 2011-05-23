//
//  GoogleTodoModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"
#import "TaskList.h"
#import "GTProtocol.h"

@interface GoogleTodoModule : BaseReporter <TaskList, GTProtocolErrorDelegate> {
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
	NSTimeInterval lookAheadWindow;
	NSTextField *lookAheadText;
	BOOL summaryMode;
	GTProtocol *protocol;
	NSDictionary *task;
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
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadLabel;
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadNote;
@property (nonatomic, retain) IBOutlet NSButton *authButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progInd;
@property (nonatomic, retain) NSMutableDictionary *alarmSet;
@property (nonatomic, retain) id<AlertHandler> handler;
@property (nonatomic, retain) NSString *lastError;
@property (nonatomic, retain) IBOutlet NSButton *isWorkButton;
@property (nonatomic) NSTimeInterval lookAheadWindow;
@property (nonatomic) BOOL summaryMode;
@property (nonatomic, retain) GTProtocol *protocol;
@property (nonatomic, retain) NSDictionary *task;

- (IBAction) clickAuthButton: (id) sender;
- (void) clickAuthorizedButton: (id) sender;
- (IBAction) clickList: (id) sender;
- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) stop;
- (void) handleRTMError:(NSDictionary*) errInfo;
- (NSDictionary*) idMapping;
@end
