//
//  GmailModule.h
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseInstance.h"
#import "RulesTableData.h"
#import "GMailRequestHandler.h"
#import "Reporter.h"

#define MAX_FAIL 3
@interface GmailModule : BaseInstance <Reporter>{
	NSTextField *userField;
	NSSecureTextField *passwordField;
	NSTextField *frequencyField;
	NSString* userStr;
	NSString *passwordStr;
	NSMutableData *respBuffer;
	NSMutableDictionary *msgDict;
	NSString *titleStr;
	NSString *summaryStr;
	NSString *idStr;
	NSString *nameStr;
	NSString *emailStr;
	NSNumber *minTagValue;
	NSTimer *refreshTimer;
	NSStepper *stepper;
	NSString *bufferStr;
	NSString *hrefStr;
	NSMutableArray *rules;
	NSTableView *rulesTable;
	NSButton *addRuleButton;
	NSButton *removeRuleButton;
	RulesTableData *rulesData;
	NSInteger failCount;
	BOOL summaryMode;
//	GMailRequestHandler *refeshHandler;
}
@property (nonatomic,retain) NSString *userStr;
@property (nonatomic,retain) NSString *titleStr;
@property (nonatomic,retain) NSString *idStr;
@property (nonatomic,retain) NSString *nameStr;
@property (nonatomic,retain) NSString *emailStr;
@property (nonatomic,retain) NSString *summaryStr;
@property (nonatomic,retain) NSString *passwordStr;
@property (nonatomic,retain) NSString *bufferStr;
@property (nonatomic,retain) NSString *hrefStr;
@property (nonatomic,retain) NSMutableData *respBuffer;
@property (nonatomic,retain) NSMutableDictionary *msgDict;
@property (nonatomic, retain) NSNumber *minTagValue;
@property (nonatomic, retain) NSTimer *refreshTimer;
@property (nonatomic, retain) IBOutlet NSTextField *userField;
@property (nonatomic, retain) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, retain) IBOutlet NSTextField *frequencyField;
@property (nonatomic, retain) IBOutlet NSStepper *stepper;
@property (nonatomic, retain) NSMutableArray* rules;
//@property (nonatomic, retain) GMailRequestHandler* refreshHandler;
@property (nonatomic, retain) IBOutlet NSTableView* rulesTable;
@property (nonatomic, retain) IBOutlet NSButton* addRuleButton;
@property (nonatomic, retain) IBOutlet NSButton* removeRuleButton;
@property (nonatomic, retain) RulesTableData *rulesData;
@property (nonatomic) NSInteger failCount;
@property (nonatomic) BOOL summaryMode;


-(IBAction) clickStepper: (id) sender;
- (void) refreshData:(GMailRequestHandler*) handler;
- (IBAction) clickAddRule: (id) sender;
- (IBAction) clickRemoveRule: (id) sender;
- (IBAction) typeChanged: (id) sender;

- (IBAction) fieldChanged: (id) sender;

- (IBAction) compareChanged: (id) sender;
- (IBAction) predicateChanged: (id) sender;
-(void) saveRules;
-(void) clearRules;
-(void) loadRules;
@end
