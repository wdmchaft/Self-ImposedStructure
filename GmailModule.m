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
@synthesize highestTagValue;
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

-(id) init
{
	self = [super init];
	if (self){
		super.description =@"Gmail Module";
		super.notificationName = @"Mail Alert";
		super.notificationTitle = @"Gmail Msg";
		minTagValue = [[NSNumber alloc]initWithInteger: 0];		
		highestTagValue = [[NSNumber alloc ]initWithLongLong:minTagValue.longLongValue];
	}	
	return self;
}
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		super.description =@"Gmail Module";
		super.notificationName = @"Mail Alert";
		super.notificationTitle = @"Gmail Msg";
		minTagValue = [[NSNumber alloc]initWithInteger: 0];		
		highestTagValue = [[NSNumber alloc ]initWithLongLong:minTagValue.longLongValue];
	}
	return self;
}

- (void)awakeFromNib
{
//	NSTableColumn *col1 = [[NSTableColumn alloc] initWithIdentifier:TYPE_COL];
//	[[col1 headerCell] setStringValue:TYPE_COL];
//	[rulesTable addTableColumn: col1];
//	[col1 setWidth:225.0];
//	NSTableColumn *col2 = [[NSTableColumn alloc] initWithIdentifier:FIELD_COL];
//	[[col2 headerCell] setStringValue:FIELD_COL];
//	[col2 setWidth:125.0];
//	[rulesTable addTableColumn: col2];
//	NSTableColumn *col3 = [[NSTableColumn alloc] initWithIdentifier:COMPARE_COL];
//	[[col3 headerCell] setStringValue:COMPARE_COL];
//	[rulesTable addTableColumn: col3];
//	NSTableColumn *col4 = [[NSTableColumn alloc] initWithIdentifier:VALUE_COL];
//	[[col4 headerCell] setStringValue:VALUE_COL];
//	[rulesTable addTableColumn: col4];	
//	
	rulesData = [[RulesTableData alloc] initWithRules:rules];
	rulesTable.dataSource = rulesData;
	[rulesTable noteNumberOfRowsChanged];
//	
//	
//	
//	
//    NSPopUpButtonCell *cell1;
//    cell1 = [[NSButtonCell alloc] init];
//    [cell1 setButtonType:NSPopUpButtonCell];
//    [cell1 setTitle:@""];
//    [cell1 setAction:@selector(toggleModule:)];
//    [cell1 setTarget:self];
//	
//	[col1 setDataCell:cell];
//	[cell release];
//		
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

-(void) refreshData: (NSTimer*) timer
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
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (!theConnection) {
		[super sendError:[NSString stringWithFormat:@"error making connection to %@",urlStr] module:[self description]];
	}
}


-(void) start
{
	super.started = YES;
	[self refreshData: nil];
}

-(void) putter
{
	//[self refreshData: nil];
}
-(void) stop
{
	if (refreshTimer){
		[refreshTimer invalidate];
	}
	refreshTimer = nil;
	super.started = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//	if ([response isKindOfClass: [NSHTTPURLResponse class]] == YES){
//		NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
//	}
    [respBuffer setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
	
	[self.respBuffer appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	
    [connection release];
	
    NSString *err = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
					 [error localizedDescription],
					 [[error userInfo] objectForKey:NSLocalizedRecoverySuggestionErrorKey]];
	[super sendError: err module: [self description]];

	if (super.validationHandler){
		[super.validationHandler performSelector:@selector(validationComplete:) 
									  withObject:[error localizedDescription]];
	}
	//[refreshTimer invalidate];
}

- (void) addEntry
{
	NSNumber *tagVal = [self getIdTagValue: idStr];
//	NSLog(@"addEntry %qu", minTagValue.longLongValue);
//	NSLog(@"check entry tagVal = %qu", tagVal.longLongValue);
	if (tagVal.longLongValue > minTagValue.longLongValue) {
		if (tagVal.longLongValue > highestTagValue.longLongValue){
//			NSLog(@"setting new high val:%qu", tagVal.longLongValue);
//			NSLog(@"for msg :%@", titleStr);
			highestTagValue = tagVal;
		}
		NSDictionary *entryDict = [[NSDictionary alloc]initWithObjectsAndKeys:
								   summaryStr,@"summary",
								   titleStr, @"title",
								   nameStr, @"name",
								   emailStr, @"email",
								   hrefStr, @"href",
								   nil];
		[msgDict setObject:entryDict forKey: titleStr];	
	}
	
}
#define ERRSTR @"<HEAD>\n<TITLE>Unauthorized</TITLE>\n</HEAD>"

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *respStr = [[[NSString alloc] initWithData:respBuffer encoding:NSUTF8StringEncoding]autorelease];

	// schedule another refresh 
	if (!super.validationHandler){
		[self scheduleNextRefresh];
	}
	// look for errors now
	NSRange errRange = [respStr rangeOfString:ERRSTR];
	
	if (errRange.location != NSNotFound){
		// Authentication failure occurred
		
		if (!super.validationHandler){
			failCount++;
			if (failCount > MAX_FAIL){
				[super sendError:@"Authentication Failure" module:[self description]];
			}
			NSLog(@"AUTHENTICATION FAILURE #%d", failCount);
			return;
		} else {
			[super.validationHandler performSelector:@selector(validationComplete:) 
										  withObject:[NSString stringWithFormat:@"Gmail account fails to authenticate.  (Perhaps retry password.)"]];		
		}
	} 
	else if (super.validationHandler){
		[super.validationHandler performSelector:@selector(validationComplete:) 
									  withObject:nil];
	}
	failCount = 0;
//	NSLog(@"%@", [[NSString alloc] initWithData: respBuffer encoding:NSUTF8StringEncoding]);
	msgDict = [NSMutableDictionary new];
	XMLParse *parser = [[XMLParse alloc]initWithData: respBuffer andDelegate: self];
	[parser parseData];
	if (titleStr != nil) {
		[self addEntry];
	}

	NSString *key = nil;
	NSDictionary *item = nil;
	for (key in msgDict){
		item = [msgDict objectForKey: key];	
		FilterResult res = [FilterRule processFilters:rules forMessage: msgDict];
		if (res != RESULT_IGNORE) {
			Note *alert = [[Note alloc]init];
			alert.moduleName = super.description;
			alert.title =key;
			alert.message=[item objectForKey:@"summary"];
			alert.sticky = (res == RESULT_IMPORTANT);
			alert.urgent = (res == RESULT_IMPORTANT);
			NSString *href = [item objectForKey:@"href"];
			alert.params = [[NSDictionary alloc] initWithObjectsAndKeys:href, @"href",
							[self description],@"module",nil ];
			[[super handler] handleAlert:alert];
		}
	}
	if (highestTagValue.longLongValue > minTagValue.longLongValue){
		//NSLog(@" new min value = %qu", highestTagValue.longLongValue);
		minTagValue = [highestTagValue copy];
		[super saveDefaultValue: minTagValue forKey: MINTAGVALUE];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void) handleClick:(NSDictionary *)ctx
{
	NSString *href = [ctx objectForKey:@"href"];
	NSURL *url = [NSURL URLWithString:href];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) scheduleNextRefresh
{
	NSTimeInterval timeRef = refresh * 60;
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeRef
										   target:self 
										 selector: @selector(refreshData:) 
										 userInfo:nil
										  repeats:NO];

}
- (void)parser:(NSXMLParser *)parser 
didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
{
	// End Element Processing
    if ( [elementName isEqualToString:@"entry"]) {
		[self addEntry];
	}
    else if ( [elementName isEqualToString:@"title"]) {
		titleStr = bufferStr;
    } else if ( [elementName isEqualToString:@"summary"]) {
		summaryStr = bufferStr;
    } else if ( [elementName isEqualToString:@"id"]) {
		idStr = bufferStr;
	} else if ( [elementName isEqualToString:@"name"]){
		nameStr = bufferStr;
	} else if ( [elementName isEqualToString:@"email"]){
		emailStr = bufferStr;
	}
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
	if ([elementName isEqualToString:@"link"]){
		hrefStr=[attributeDict objectForKey:@"href"];
	}
	bufferStr = [NSString new];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	bufferStr = [bufferStr stringByAppendingString:string];	
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
		[super.validationHandler performSelector:@selector(validationComplete:) 
									  withObject:nil];
	}
	else{
		userStr = userField.stringValue;
		
		passwordStr = passwordField.stringValue;
		[self refreshData: nil];
	}
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
		minTagValue = temp;
	}
	[self loadRules];
}

-(void) clearDefaults{
	[super clearDefaults];
	[super clearDefaultValue:userField.stringValue forKey:EMAIL];
	[super clearDefaultValue:passwordField.stringValue forKey:PASSWORD];
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
