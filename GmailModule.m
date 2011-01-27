//
//  GmailModule.m
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "GmailModule.h"
#import "Note.h"
#import "Utility.h"
#import "XMLParse.h"
#import "FilterRule.h"

#define EMAIL @"Email"
#define PASSWORD @"Password"
#define REFRESH @"Refresh"
#define MINTAGVALUE @"MinTagValue"
#define RULECOUNT @"RuleCount"
#define RULE @"Rule"

@implementation GmailModule
@synthesize userStr;
@synthesize passwordStr;
@synthesize respBuffer;
@synthesize refresh;
@synthesize msgDict;
@synthesize titleStr;
@synthesize summaryStr;
@synthesize idStr;
@synthesize minTagValue;
@synthesize userField;
@synthesize passwordField;
@synthesize frequencyField;
@synthesize refreshTimer;
@synthesize stepper;
@synthesize nameStr;
@synthesize emailStr;
@synthesize bufferStr;
@synthesize hrefStr;
@synthesize rules;
@synthesize rulesTable;
@synthesize addRuleButton;
@synthesize removeRuleButton;
@synthesize rulesData;
@synthesize failCount;
@synthesize summaryMode;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		description =@"Gmail Module";
		notificationName = @"Mail Alert";
		notificationTitle = @"Gmail Msg";
		minTagValue = [[NSNumber alloc]initWithInteger: 0];		
	}
	return self;
}

- (void)awakeFromNib
{

	rulesData = [[RulesTableData alloc] initWithRules:rules];
	rulesTable.dataSource = rulesData;
	[rulesTable noteNumberOfRowsChanged];
	
}

-(NSNumber*) getIdTagValue: (NSString*) tag
{
	NSAssert([tag length] < 100, @"ID is too long");
	NSArray *comps = [tag componentsSeparatedByString:@":"];
	int compsCount = [comps count];
	NSString *number = [comps objectAtIndex:compsCount - 1];
//	NSLog(@"id number = %@", number);
	return [NSNumber numberWithLongLong:number.longLongValue];
}

-(void) refreshData: (GMailRequestHandler*) refreshHandler
{
	refreshTimer = nil;

	NSString *host = [[NSString alloc] initWithString:@"https://mail.google.com"];
	NSString *urlStr = [[NSString alloc]initWithFormat: @"%@%@",host,@"/mail/feed/atom"];
	NSURL *url = [[[NSURL alloc]initWithString:urlStr]autorelease];
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url];
	NSString *credentials = [[NSString alloc]initWithFormat:@"%@:%@",userStr,passwordStr ];
	credentials = [Utility base64EncodedString: [credentials UTF8String] withLength: [credentials length]];
	NSString *authStr = [[NSString alloc]initWithFormat:@"Basic %@", credentials ];
	//NSLog(@"auth str = [%@]", authStr);
	[theRequest addValue:authStr forHTTPHeaderField: @"Authorization"];
	respBuffer = [[NSMutableData alloc]init];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:refreshHandler];
	if (!theConnection) {
		[BaseInstance sendErrorToHandler:refreshHandler.alertHandler 
								   error:[NSString stringWithFormat:@"error making connection to %@",urlStr] 
								  module:[self description]];
	}
}

-(void) didFinishRequest: (GMailRequestHandler*) handler
{
	minTagValue = handler.minTagValue;
	[super saveDefaultValue:minTagValue forKey:MINTAGVALUE];
}

- (void) refresh: (<AlertHandler>) AlertHandler{
	
	GMailRequestHandler *refreshHandler = 
		[[GMailRequestHandler alloc] initWithTagValue: minTagValue 
												rules: rules 
											  handler: AlertHandler
											 delegate:self];
	[self refreshData:refreshHandler];
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
	refresh = frequencyField.intValue;
	// 
	// if the password / user already are set and haven't changed 
	// then don't bother connecting to validate
	//
	if (passwordStr != nil 
		&& userStr != nil 
		&& [passwordStr isEqualToString:passwordField.stringValue]
		&& [userStr isEqualToString:userField.stringValue]) {
		[validationHandler performSelector:@selector(validationComplete:) 
									  withObject:nil];
	}
	else{
		userStr = userField.stringValue;
		
		passwordStr = passwordField.stringValue;
		GMailRequestHandler *handler = [[GMailRequestHandler alloc] initForValidation:[super validationHandler]];
		[self refreshData:handler];	}
}

-(void) saveDefaults{ 
	[super saveDefaults];
	[super saveDefaultValue:userStr forKey:EMAIL];
	[super saveDefaultValue:passwordStr forKey:PASSWORD];
	[super saveDefaultValue:[NSNumber numberWithInt:refresh] forKey:REFRESH];
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

	[userField setStringValue:userStr == nil ? @"" : userStr];
	[passwordField setStringValue:passwordStr == nil ? @"" : passwordStr];
	[frequencyField setStringValue:[NSString stringWithFormat:@"%d", refresh]];
	rulesData.allRules = rules;
	rulesTable.dataSource = rulesData;
}

-(void) loadDefaults
{
	[super loadDefaults];
	passwordStr = [super loadDefaultForKey:PASSWORD];
	userStr = [super loadDefaultForKey:EMAIL];
	NSNumber *temp =  [super loadDefaultForKey:REFRESH];
	if (temp) {
		refresh = [temp intValue];
	}
	temp = [super loadDefaultForKey:MINTAGVALUE];
	if (temp) {
		minTagValue = [[NSNumber alloc]initWithLongLong:((NSNumber*) temp).longLongValue];
	}
	[self loadRules];
}

-(void) clearDefaults{
	[super clearDefaults];
	[super clearDefaultValue:userField.stringValue forKey:EMAIL];
	[super clearDefaultValue:passwordField.stringValue forKey:PASSWORD];
	[super clearDefaultValue:[NSNumber numberWithInt:frequencyField.intValue] forKey:REFRESH];
	[super clearDefaultValue:[NSNumber numberWithInt:0] forKey:MINTAGVALUE];
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
