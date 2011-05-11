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
#import "Stateful.h"

@interface AppleMailModule : BaseReporter <Stateful> {
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
    NSMutableArray *rules;
	NSTableView *rulesTable;
	NSButton *addRuleButton;
	NSButton *removeRuleButton;
	RulesTableData *rulesData;
    BOOL summaryMode;
    NSDateFormatter *mailDateFmt;
    NSString* msgName;
    NSMutableArray *newestMail;
    NSNumberFormatter* displayWindowFmt;
	NSMutableDictionary *threadCache;
	NSDate *lastRefresh;
	SEL fetchCallback;
	NSString* errStr;
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
@property (nonatomic, retain) IBOutlet NSTableView* rulesTable;
@property (nonatomic, retain) IBOutlet NSButton* addRuleButton;
@property (nonatomic, retain) IBOutlet NSButton* removeRuleButton;
@property (nonatomic, retain) IBOutlet NSNumberFormatter* displayWindowFmt;
@property (nonatomic, retain) RulesTableData *rulesData;
@property (nonatomic, retain) NSDateFormatter *mailDateFmt;
@property (nonatomic, retain) NSString *msgName;
@property (nonatomic, retain) NSMutableDictionary *threadCache;
@property (nonatomic) BOOL summaryMode;
@property (nonatomic, retain) NSDate *lastRefresh;
@property (nonatomic) SEL fetchCallback;
@property (nonatomic, retain) NSString* errStr;

- (void) validateDone: (NSNotification*) note;
- (void) doValidate: (NSObject*) params;

- (IBAction) clickAddRule: (id) sender;
- (IBAction) clickRemoveRule: (id) sender;
- (IBAction) typeChanged: (id) sender;
- (IBAction) fieldChanged: (id) sender;
- (IBAction) compareChanged: (id) sender;
-(IBAction) predicateChanged: (id) sender;

@end
