//
//  RTMModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMCallback.h"
#import "BaseReporter.h"
#import "TaskList.h"

@interface RTMModule : BaseReporter <TaskList, RTMCallback>{
	NSString *tokenStr;
	NSString *userStr;
	NSString *passwordStr;
	NSString *frobStr;
	NSString *listNameStr;
	NSString *timelineStr;

	NSMutableDictionary *idMapping;
	NSMutableDictionary *tasksDict;
	NSString *listIdStr;
	NSMutableArray *tasksList;
	NSTextField *userText;
	NSSecureTextField *passwordText;
	NSTextField *refreshText;
	NSPopUpButton *listsCombo;
	NSStepper *refreshStepper;
	NSTextField *comboLabel;
	NSTextField *stepperLabel;
	NSTextField *refreshLabel;
	NSButton *authButton;
	BOOL firstClick;
	NSProgressIndicator *progInd;	
	NSMutableDictionary *alarmSet;
	id<AlertHandler> handler;
	NSString *lastError;
    BOOL isWorkRelated;
    NSButton *isWorkButton;
	NSTimeInterval lookAheadWindow;
	NSTextField *lookAheadText;
}

@property (nonatomic, retain) NSString *tokenStr;
@property (nonatomic, retain) NSString *frobStr;
@property (nonatomic, retain) NSString *userStr;
@property (nonatomic, retain) NSString *passwordStr;
@property (nonatomic, retain) NSString *listNameStr;
@property (nonatomic, retain) NSString *listIdStr;
@property (nonatomic, retain) NSString *timelineStr;
@property (nonatomic, retain) NSMutableDictionary *idMapping;
@property (nonatomic, retain) NSMutableDictionary *tasksDict;
@property (nonatomic, retain) NSMutableArray *tasksList;
@property (nonatomic, retain) IBOutlet NSTextField *userText;
@property (nonatomic, retain) IBOutlet NSTextField *refreshText;
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadText;
@property (nonatomic, retain) IBOutlet NSSecureTextField *passwordText;
@property (nonatomic, retain) IBOutlet NSStepper *refreshStepper;
@property (nonatomic, retain) IBOutlet NSPopUpButton *listsCombo;
@property (nonatomic, retain) IBOutlet 	NSTextField *comboLabel;
@property (nonatomic, retain) IBOutlet NSTextField *stepperLabel;
@property (nonatomic, retain) IBOutlet NSTextField *refreshLabel;
@property (nonatomic, retain) IBOutlet NSButton *authButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progInd;
@property (nonatomic, retain) NSMutableDictionary *alarmSet;
@property (nonatomic, retain) id<AlertHandler> handler;
@property (nonatomic, retain) NSString *lastError;
@property (nonatomic, retain) NSButton *isWorkButton;
@property(nonatomic) BOOL firstClick;
@property (nonatomic) BOOL isWorkRelated;
@property (nonatomic) NSTimeInterval lookAheadWindow;

- (IBAction) clickRefreshStepper: (id) sender;
- (IBAction) clickAuthButton: (id) sender;
- (IBAction) clickList: (id) sender;
- (void) getLists;
- (void) updateList;
- (void) startRefresh: (NSTimer*) theTimer;
- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) stop;
- (void) handleRTMError:(NSDictionary*) errInfo;
@end
