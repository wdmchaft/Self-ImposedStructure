//
//  AppleMailModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 2/16/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
#import "BaseReporter.h"
#import "RulesTableData.h"
#import "AppleMailMonitor.h"

@interface AppleMailModule : BaseReporter {
	NSString *accountName;
	NSString *mailMailboxName;
	NSMutableArray *cachedMail;
	id<AlertHandler> alertHandler;
	NSTextField *accountField;
	NSTextField *mailboxField;
	NSTextField *refreshIntervalField;
	NSStepper *refreshIntervalStepper;
	NSTextField *displayWindowField;
	NSStepper *displayWindowStepper;
	NSTimeInterval displayWindow;
	NSDate *lastCheck;
    NSMutableArray *rules;
	NSTableView *rulesTable;
	NSButton *addRuleButton;
	NSButton *removeRuleButton;
	RulesTableData *rulesData;
    BOOL summaryMode;
    NSDateFormatter *mailDateFmt;
    AppleMailMonitor *mailMonitor;
    NSString* msgName;
    NSMutableArray *newestMail;
    NSNumberFormatter* displayWindowFmt;
}
@property (nonatomic,retain) NSString *accountName;
@property (nonatomic,retain) NSString *mailMailboxName;
@property (nonatomic,retain) NSMutableArray *cachedMail;
@property (nonatomic,retain) id<AlertHandler> alertHandler;
@property (nonatomic,retain) IBOutlet NSTextField *accountField;
@property (nonatomic,retain) IBOutlet NSTextField *mailboxField;
@property (nonatomic,retain) IBOutlet NSTextField *refreshIntervalField;
@property (nonatomic,retain) IBOutlet NSTextField *displayWindowField;
@property (nonatomic,retain) IBOutlet NSStepper *refreshIntervalStepper;
@property (nonatomic,retain) IBOutlet NSStepper *displayWindowStepper;
@property (nonatomic)  NSTimeInterval displayWindow;
@property (nonatomic,retain) NSDate *lastCheck;
@property (nonatomic, retain) IBOutlet NSTableView* rulesTable;
@property (nonatomic, retain) IBOutlet NSButton* addRuleButton;
@property (nonatomic, retain) IBOutlet NSButton* removeRuleButton;
@property (nonatomic, retain) IBOutlet NSNumberFormatter* displayWindowFmt;
@property (nonatomic, retain) RulesTableData *rulesData;
@property (nonatomic, retain) NSDateFormatter *mailDateFmt;
@property (nonatomic, retain) AppleMailMonitor *mailMonitor;
@property (nonatomic, retain) NSString *msgName;
@property (nonatomic) BOOL summaryMode;

- (void) getUnread;
- (void) fetchDone: (NSNotification*) msg;
- (void) validateDone: (NSNotification*) note;
- (void) doValidate: (NSObject*) params;

- (IBAction) clickAddRule: (id) sender;
- (IBAction) clickRemoveRule: (id) sender;
- (IBAction) typeChanged: (id) sender;
- (IBAction) fieldChanged: (id) sender;
- (IBAction) compareChanged: (id) sender;
-(IBAction) predicateChanged: (id) sender;

@end
