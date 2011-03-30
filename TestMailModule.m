//
//  GmailModule.m
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "TestMailModule.h"
#import "Note.h"


#define REFRESH @"Refresh"
#define RULECOUNT @"RuleCount"
#define RULE @"Rule"

@implementation TestMailModule

@synthesize refresh;

@synthesize frequencyField;
@synthesize stepper;
@synthesize rules;
@synthesize rulesTable;
@synthesize addRuleButton;
@synthesize removeRuleButton;
@synthesize rulesData;
@dynamic notificationTitle;
@dynamic notificationName;
@dynamic refreshInterval;
@dynamic enabled;
@dynamic category;
@dynamic name;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		name =@"Test Mail Module";
		notificationName = @"Mail Alert";
		notificationTitle = @"Test Email Msg";
		category = CATEGORY_EMAIL;
		summaryTitle = @"Test Mail";
	}
	return self;
}

- (void)awakeFromNib
{
	rulesData = [[RulesTableData alloc] initWithRules:rules];
	rulesTable.dataSource = rulesData;
	[rulesTable noteNumberOfRowsChanged];
	refresh= 60;
}


-(void) refreshData: (id<AlertHandler>) handler 
{
	NSDate *now = [NSDate date];
	NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
						   [self name], @"module",
						   @"this is a summary",@"summary",
						   @"title for summary",@"title",
						   @"Mark Ratner",@"name",
						   @"ratner@fasttimes.com",@"email",
						   @"http://fasttimes.com",@"href",
						   now, @"received",
						   nil];
	NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
						   [self name], @"module",
						   @"We still on for Pizza?",@"summary",
						   @"Hey Mr. Hand!",@"title",
						   @"Jeff Spicolli",@"name",
						   @"spicolli@fasttimes.com",@"email",
						   @"http://fasttimes.com",@"href",
						   [NSDate dateWithTimeIntervalSinceNow:-660.0], @"received",
   nil];
	NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:
						   [self name], @"module",
						   @"Dude where's my car?",@"summary",
						   @"more stoner humor",@"title",
						   @"That Guy",@"name",
						   @"that.guy@wheresmycar.com",@"email",
						   @"http://wheresmycar.com",@"href",
						   [NSDate dateWithTimeIntervalSinceNow:-120.0], @"received",
						   nil];
	NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:
						   [self name], @"module",
						   @"User Id Enclosed",@"summary",
						   @"Get Fast Refund From Turbo Tax",@"title",
						   @"Quicken",@"name",
						   @"alert@quicken.com", @"email",
						   @"http://quicken.com",@"href",
						   [NSDate dateWithTimeIntervalSinceNow:-360.0], @"received",
						   nil];
	NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:
						   [self name], @"module",
						   @"Unimportant Message",@"summary",
						   @"ignorance is bliss",@"title",
						   @"That Boring Guy",@"name",
						   @"that.unimportant.guy@wheresmycar.org",@"email",
						   @"http://unimportant.com", @"href",
						   [NSDate dateWithTimeIntervalSinceNow:-480.0], @"received",
						   nil];
    //	NSArray *msgs = [NSArray arrayWithObjects: dict1,dict2,dict3,dict4,dict5,nil];
    NSArray *msgs = [NSArray arrayWithObjects:nil];
	NSMutableArray *sendItems = [NSMutableArray new];
	for (NSDictionary *item in msgs){
        NSColor *color;
		FilterResult res = [FilterRule processFilters:rules forMessage: item color: &color];
		if (res != RESULT_IGNORE) {
			[sendItems addObject:item];
		}
	}
	
	for (int i = 0; i < [sendItems count];i++){
		NSDictionary *item = [sendItems objectAtIndex:i];
		Note *alert = [[Note alloc]init];
        NSColor *color;
		FilterResult res = [FilterRule processFilters:rules forMessage: item color:&color];
		alert.moduleName = name;
		alert.title =[item objectForKey:@"title"];
		alert.message=[item objectForKey:@"summary"];
		alert.sticky = (res == RESULT_IMPORTANT);
		alert.urgent = (res == RESULT_IMPORTANT);
		alert.clickable = YES;
		alert.params = item;
		[handler handleAlert:alert];
	}
	[BaseInstance sendDone: handler module: name];	
}

-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary
{
	[self refreshData:handler];
}

- (void) handleClick:(NSDictionary *)ctx
{
	NSString *href = [ctx objectForKey:@"href"];
	NSURL *url = [NSURL URLWithString:href];
	[[NSWorkspace sharedWorkspace] openURL:url];
}


- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	refreshInterval = frequencyField.intValue * 60;
	[validationHandler performSelector:@selector(validationComplete:) 
							withObject:nil];
}

-(void) saveDefaults{ 
	[super saveDefaults];
	[super saveDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[self saveRules];
	[[NSUserDefaults standardUserDefaults] synchronize];
};

- (void) saveRules
{
	[super saveDefaultValue:[NSNumber numberWithInt:[rules count]] forKey:RULECOUNT];
	int count = 0;
	for (FilterRule *rule in rules){
		NSString *str = [NSString stringWithFormat:@"%d_%d_%d_%@", rule.ruleType, rule.fieldType, rule.compareType, rule.predicate];
		NSString *key = [NSString stringWithFormat:@"%@_%d",RULE,count ];
		[super saveDefaultValue:str forKey:key];
		count++;
	}
}

- (void) loadRules
{
	NSNumber *temp = [super loadDefaultForKey:RULECOUNT];
	int count = [temp intValue];
	for (int x = 0; x < count; x++){
		NSString *key = [NSString stringWithFormat:@"%@_%d",RULE,x ];
		NSString *val = [super loadDefaultForKey:key];
		FilterRule *rule = [[FilterRule alloc]initFromString:val];
		if (rules == nil){
			rules = [NSMutableArray new];
		}
		[rules addObject:rule];
	}
}

- (void) clearRules
{
	NSNumber *temp = [super loadDefaultForKey:RULECOUNT];
	int count = [temp intValue];
	for (int x = 0; x < count; x++){
		NSString *key = [NSString stringWithFormat:@"%@_%d",RULE,count ];
		NSString *val = [super loadDefaultForKey:key];
		[super clearDefaultValue:val forKey:key];
	}
}

-(void) loadView
{
	[super loadView];
	[frequencyField setStringValue:[NSString stringWithFormat:@"%d", refreshInterval/60]];
	rulesData.allRules = rules;
	rulesTable.dataSource = rulesData;
}

-(void) loadDefaults
{
	[super loadDefaults];
	NSNumber *temp =  [super loadDefaultForKey:REFRESH];
	if (temp) {
		refreshInterval = [temp intValue];
	}
	[self loadRules];
}

-(void) clearDefaults{
	[super clearDefaults];
	
	[super clearDefaultValue:[NSNumber numberWithInt:frequencyField.intValue] forKey:REFRESH];
	[self clearRules];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(IBAction) clickStepper: (id) sender
{
	frequencyField.intValue = stepper.intValue;
}

- (IBAction) clickAddRule: (id) sender
{
	FilterRule *rule = [FilterRule new];
	rule.predicate = @"";
	if (!rules){
		rules = [NSMutableArray new];
		rulesData.allRules = rules;
	}
	[rules addObject:rule];
	[rulesTable noteNumberOfRowsChanged];
}

- (IBAction) clickRemoveRule: (id) sender
{
	NSInteger idx = [rulesTable selectedRow];
	if (idx < 0){
		return;
	}
	[rules removeObjectAtIndex:idx];
	[rulesTable noteNumberOfRowsChanged];
}

- (IBAction) typeChanged: (id) sender
{
	NSTableView* tView = (NSTableView*)sender;
	NSInteger rowIdx = [tView selectedRow];
	NSPopUpButtonCell *pop = [tView selectedCell];
	int idx = [pop indexOfSelectedItem];
	FilterRule *rule = [rules objectAtIndex:rowIdx];
	rule.ruleType = idx;
	
	//   NSLog(@"cell idx  = %d", idx);
	//   NSLog(@"cell title = %@", [pop titleOfSelectedItem]);
}
- (IBAction) fieldChanged: (id) sender
{
	NSTableView* tView = (NSTableView*)sender;
	NSInteger rowIdx = [tView selectedRow];
	NSPopUpButtonCell *pop = [tView selectedCell];
	int idx = [pop indexOfSelectedItem];
	FilterRule *rule = [rules objectAtIndex:rowIdx];
	rule.fieldType = idx;
}
- (IBAction) compareChanged: (id) sender
{
	NSTableView* tView = (NSTableView*)sender;
	NSInteger rowIdx = [tView selectedRow];
	NSPopUpButtonCell *pop = [tView selectedCell];
	int idx = [pop indexOfSelectedItem];
	FilterRule *rule = [rules objectAtIndex:rowIdx];
	rule.compareType = idx;
}

-(IBAction) predicateChanged: (id) sender
{
	NSTableView* tView = (NSTableView*)sender;
	NSInteger rowIdx = [tView selectedRow];
	NSTextFieldCell *cell = [tView selectedCell];
	FilterRule *rule = [rules objectAtIndex:rowIdx];
	rule.predicate = [cell stringValue];
}
@end
