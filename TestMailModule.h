//
//  GmailModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseInstance.h"
#import "RulesTableData.h"
#import "BaseReporter.h"

#define MAX_FAIL 3
@interface TestMailModule : BaseReporter {

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
