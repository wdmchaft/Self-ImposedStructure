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
#import "Reporter.h"

#define MAX_FAIL 3
@interface TestMailModule : BaseInstance <Reporter> {

	NSTextField *frequencyField;

	NSTimeInterval refresh;
	NSString *titleStr;

	NSStepper *stepper;

	NSString *hrefStr;
	NSMutableArray *rules;
	NSTableView *rulesTable;
	NSButton *addRuleButton;
	NSButton *removeRuleButton;
	RulesTableData *rulesData;
}

@property (nonatomic) NSTimeInterval refresh;
@property (nonatomic, retain) IBOutlet NSTextField *frequencyField;
@property (nonatomic, retain) IBOutlet NSStepper *stepper;
@property (nonatomic, retain) NSMutableArray* rules;
@property (nonatomic, retain) IBOutlet NSTableView* rulesTable;
@property (nonatomic, retain) IBOutlet NSButton* addRuleButton;
@property (nonatomic, retain) IBOutlet NSButton* removeRuleButton;
@property (nonatomic, retain) RulesTableData *rulesData;
@property (nonatomic) BOOL summaryMode;


-(IBAction) clickStepper: (id) sender;
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
