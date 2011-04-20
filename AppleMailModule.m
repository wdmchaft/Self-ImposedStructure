//
//  AppleMailModule.m
//  Self-Imposed Structure
//
//  Created by Charles on 2/16/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "AppleMailModule.h"
#import "Mail.h"
#import "MimeHandler.h"
#import "Utility.h"
#import "ColorWellCell.h"
#import "VariableTableColumn.h"

#define MAILBOX @"mailMailbox"
#define ACCOUNT @"account"
#define REFRESH  @"refreshInterval"
#define DISPLAYWIN  @"displayWindow"
#define USEDISPWIN  @"useDisplayWindow"
#define LASTCHECK  @"lastCheck"
#define RULECOUNT @"RuleCount"
#define RULE @"Rule"
#define RULE_COLORS @"RuleColors"
#define RULE_PREDS @"RulePredicates"
#define RULE_TYPES @"RuleTypes"
#define RULE_COMPARES @"RuleCompares"
#define RULE_FIELDS @"RuleFields"

@implementation AppleMailModule

@synthesize accountName;
@synthesize accountField;
@synthesize mailMailboxName;
@synthesize mailboxField;
@synthesize unreadMail;
@synthesize alertHandler;
@synthesize refreshIntervalField;
@synthesize refreshIntervalStepper;
@synthesize displayWindow;
@synthesize displayWindowField;
@synthesize displayWindowStepper;
@synthesize useDisplayWindow;
@synthesize useDisplayWindowButton;
@synthesize lastCheck;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;
@dynamic summaryTitle;
@synthesize rulesData, rulesTable, removeRuleButton, addRuleButton, summaryMode;
@synthesize mailDateFmt;
@synthesize msgName;
@synthesize mailMonitor;

- (void)awakeFromNib
{
    
	rulesData = [[RulesTableData alloc] initWithRules:rules];
	rulesTable.dataSource = rulesData;
	[rulesTable noteNumberOfRowsChanged];
	
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		name =@"Apple Mail Module";
		notificationName = @"Mail Alert";
		notificationTitle = @"Mail Msg";
		category = CATEGORY_EMAIL;
		summaryTitle = @"Apple Mail";
	}
	return self;
}

- (NSDate*) lastCheck{
    if (lastCheck){
        return lastCheck;
    }
    lastCheck = [[NSUserDefaults standardUserDefaults] objectForKey:[super myKeyForKey:LASTCHECK]];
    if (lastCheck){
        return lastCheck;
    }  
    lastCheck =  [[NSDate date] dateByAddingTimeInterval:-(24 * 60 * 60)]; // nothing set - get the last day of msgs
    return lastCheck;
}

- (NSString*) stripWhite: (NSString*) inStr
{
    NSRange range = [inStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (range.location == 0){
        return [inStr substringFromIndex:range.length];
    }
    return inStr;
}

- (NSString*) stripRe: (NSString*) inStr
{
    NSString *test = [self stripWhite:[inStr uppercaseString]];
    while ([test hasPrefix:@"RE:"]){
        test = [test substringFromIndex:3];
        test = [self stripWhite:test];
    }
    return test;
}

- (NSString*) msgName
{
    if (!msgName){
        NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
        msgName = [@"com.zer0gravitas.iCalDone" stringByAppendingString:[[NSNumber numberWithDouble:ti] stringValue]];
    }
    return msgName;
}

/**
 * make threads for messages with equivalent subject headers
 */
- (void) processThreads
{
    NSMutableArray *newUnread = [NSMutableArray arrayWithCapacity:[unreadMail count]];
    NSMutableDictionary *threadDict = [NSMutableDictionary dictionaryWithCapacity:[unreadMail count]];
    // now run through the mail and look for threads 
    for (NSMutableDictionary *msg in unreadMail){
        NSString *subj = [self stripRe:[msg objectForKey:MAIL_SUBJECT]];
        
        NSMutableDictionary *match = [threadDict objectForKey:subj];
        if (match){
            NSMutableArray *thread = [match objectForKey:@"THREAD"];
            if (!thread){
                thread = [NSMutableArray new];
                [match setObject:thread forKey:@"THREAD"];
                [match setObject:[NSNumber numberWithBool:NO] forKey:@"EXPANDED"];
            }
            [thread addObject:msg];
        }
        else {
            [threadDict setObject:msg forKey:subj];
            [newUnread addObject:msg];
        }
    }
    /** replace unreadMail with threadedUnreadMail **/
    unreadMail = newUnread;
     
}
-(void) getUnread
{
	NSDate *minTime = [NSDate distantPast];
    
	if (summaryMode && useDisplayWindow){
		minTime = [[NSDate date] dateByAddingTimeInterval:-(displayWindow * 60 * 60)];
        // the window may be longer than the default window if we haven't checked the inbox in a while
        minTime = [[self lastCheck] earlierDate:minTime];
	} else if (!summaryMode){
        minTime = [self lastCheck];
    }
    
    NSLog(@"starting getUnread w/ received later than %@", minTime);    
 //   NSDate *today = [NSDate date];
    if (mailDateFmt == nil){
        mailDateFmt = [NSDateFormatter new];
        [mailDateFmt setDateFormat:@"EEEE, MMMM dd, yyyy hh:mm:ss a"];
    }
//    NSString *nowStr = [mailDateFmt stringFromDate:today];
    NSString *thenStr = [mailDateFmt stringFromDate:minTime];
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle resourcePath];
    path = [path stringByAppendingFormat:@"/%@",@"mailFetchTemplate.txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    script = [script stringByReplacingOccurrencesOfString:@"<actName>" withString:accountName];
    script = [script stringByReplacingOccurrencesOfString:@"<boxName>" withString:mailMailboxName];
    script = [script stringByReplacingOccurrencesOfString:@"<sDate>" withString:thenStr];
    mailMonitor = [AppleMailMonitor appleMailShared];
    NSLog(@"script = %@",script);
    [mailMonitor sendScript:script withCallback:[self msgName]];
}

-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary
{
	alertHandler = handler;
    summaryMode = summary;
    if (!unreadMail) {
        unreadMail = [NSMutableArray new];
    }
    [unreadMail removeAllObjects];
    NSLog(@"msg = %@",[self msgName]);
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fetchDone:)
												 name:[self msgName] 
											   object:nil];
    
	[self getUnread];
}

- (void) handleMessageDescriptor:(NSAppleEventDescriptor*) descN
{
    NSMutableDictionary *eDict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    for(unsigned int j = 1; j <= [descN numberOfItems]; j+=2){
        NSLog(@"descN[%d]", j);
        NSAppleEventDescriptor *fieldNameDesc = [descN descriptorAtIndex:j];
        NSAppleEventDescriptor *fieldValDesc = [descN descriptorAtIndex:j+1];
        
        // typeType (aka '    ') means the result is an empty string (which means nil in this case)
        if ([fieldValDesc descriptorType] != typeType) {

            NSString *fieldName = [fieldNameDesc stringValue];
            if ([fieldName isEqualToString:@"rDate"]){
                NSString *dateTemp = [fieldValDesc stringValue];
                NSDate *date = [mailDateFmt dateFromString:dateTemp];
                [eDict setValue:date forKey:MAIL_ARRIVAL_TIME];
            }   
            if ([fieldName isEqualToString:@"sDate"]){
                NSString *dateTemp = [fieldValDesc stringValue];
                NSDate *date = [mailDateFmt dateFromString:dateTemp];
                [eDict setValue:date forKey:MAIL_SENT_TIME];
            }  
            if ([fieldName isEqualToString:@"subj"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_SUBJECT];
            } 
            if ([fieldName isEqualToString:@"cont"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_SUMMARY];
            } 
            if ([fieldName isEqualToString:@"unique"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:@"id"];
            } 
            if ([fieldName isEqualToString:@"sendr"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_NAME];
            } 
            if ([fieldName isEqualToString:@"mailr"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_EMAIL];
            } 
            if ([fieldName isEqualToString:@"stat"]){
                [eDict setValue:[NSNumber numberWithBool:[fieldValDesc booleanValue]] forKey:@"readStatus"];
            } 
        }
    }
    [unreadMail addObject:eDict];                 
}

- (void) handleDescriptor: (NSAppleEventDescriptor*) aDescriptor
{
    char *c = nil;
    DescType type = [aDescriptor descriptorType];
    if (type == typeAERecord) {
        [self handleMessageDescriptor:aDescriptor];
    }
    else if (type == typeAEList) {
        NSAssert(type == typeAEList, @"not a list!");
        for(unsigned int i = 1; i <= [aDescriptor numberOfItems]; i++){
            NSAppleEventDescriptor *descN = [aDescriptor descriptorAtIndex:i];
            DescType typeN = [descN descriptorType];
            NSAssert(typeN == typeAERecord, @"not a record");
            c = (char*)&type;
            NSLog(@"descN[%d] = %c%c%c%c (%@)",i, c[3],c[2],c[1],c[0], [descN description]);
            for(unsigned int j = 1; j <= [descN numberOfItems]; j++){
                AEKeyword kw = [descN keywordForDescriptorAtIndex:j];
                NSAppleEventDescriptor *fdesc0 = [descN descriptorForKeyword:kw];
                //  DescType fldDesc = [fdesc0 descriptorType];
                [self handleMessageDescriptor:fdesc0];
                
            }
        }
    }
    else {
        c = (char*)&type;
        NSLog(@"unexpected event descriptor: %c%c%c%c (%@)",c[3],c[2],c[1],c[0], [aDescriptor description]);
    }
}

- (void) fetchDone: (NSNotification*) note
{
    NSAppleEventDescriptor *eventRes = [[[AppleMailMonitor appleMailShared] eventRes] copy];
    NSDictionary *eventErr = [[[AppleMailMonitor appleMailShared] errorRes] copy];
    [[AppleMailMonitor appleMailShared] sendDone];
    if (eventErr){
        NSLog(@"got Error! %@", eventErr);
    }
    else {
        [self handleDescriptor:eventRes];
        NSMutableArray *mailToSend = [NSMutableArray arrayWithCapacity:[unreadMail count]];
        for (NSMutableDictionary *msg in unreadMail){
            NSColor *ruleColor = nil;
            FilterResult res = [FilterRule processFilters:rules 
                                               forMessage: msg
                                                    color: &ruleColor];
            if (ruleColor){
                [msg setValue:ruleColor forKey:MAIL_COLOR];
            }
            if (res == RESULT_SUMMARYONLY){
                if (!summaryMode)
                    [mailToSend addObject:msg];
            } else if (res != RESULT_IGNORE) {
                [mailToSend addObject:msg];
            }
        }
        
        for (NSDictionary *msg in mailToSend)
        {
            WPAAlert *alert = [WPAAlert new];
            
            alert.moduleName = name;
            alert.title = [NSString stringWithFormat:@"From: %@",[msg objectForKey:MAIL_EMAIL]];;
            alert.message=[msg objectForKey:MAIL_SUMMARY];
            alert.sticky = NO;
            alert.urgent = NO;
            alert.params = msg;
            alert.clickable = YES;
			
            [alertHandler handleAlert:alert];
        }
    }

	[BaseInstance sendDone:alertHandler module: name];	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self msgName] object:nil];
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	accountName = [accountField stringValue];
	mailMailboxName = [mailboxField stringValue];
	useDisplayWindow = [useDisplayWindowButton intValue];
	displayWindow = [displayWindowField doubleValue];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(validateDone:)
												 name:@"com.zer0gravitas.validateDone" 
											   object:nil];
	[NSThread detachNewThreadSelector: @selector(doValidate:)
							 toTarget:self
						   withObject:nil];	

}

- (void) doValidate: (NSObject*) params
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	MailAccount *foundAcc = nil;
	BOOL foundBox = NO;
	NSString *err = nil;
	MailApplication *mailApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.mail"];
	if (mailApp) {
		for (MailAccount *mAcc in mailApp.accounts){
			if ([mAcc.name isEqualToString:accountName]){
				foundAcc = mAcc;
			}
		}
		if (foundAcc) {
			for(MailMailbox *box in foundAcc.mailboxes){
				if ([box.name isEqualToString: mailMailboxName]) {
					foundBox = YES;
				}
			}
			if (!foundBox) {
				err = [NSString stringWithFormat:@"No mailbox named: '%@'",mailMailboxName];
			}
		}
		else {
			err = [NSString stringWithFormat:@"No account named: '%@'",accountName];
		}

	}
	else {
		err = @"Apple Mail not running: can not validate.";
	}
	NSNotification *msg = [NSNotification notificationWithName:@"com.zer0gravitas.validateDone" object:err];
	[[NSNotificationCenter defaultCenter] postNotification:msg];
	[pool drain];
}

- (void) validateDone: (NSNotification*) note
{
	[validationHandler performSelector:@selector(validationComplete:) 
								withObject:note.object];
}

- (void) saveRules
{
    NSMutableArray *aryFields = [NSMutableArray arrayWithCapacity:[rules count]];
    NSMutableArray *aryTypes = [NSMutableArray arrayWithCapacity:[rules count]];
    NSMutableArray *aryColors = [NSMutableArray arrayWithCapacity:[rules count]];
    NSMutableArray *aryPredicates = [NSMutableArray arrayWithCapacity:[rules count]];
    NSMutableArray *aryCompares = [NSMutableArray arrayWithCapacity:[rules count]];
    for (FilterRule *rule in rules){
        [aryFields addObject:[NSNumber numberWithInt:rule.fieldType]];
        [aryCompares addObject:[NSNumber numberWithInt:rule.compareType]];
        [aryTypes addObject:[NSNumber numberWithInt:rule.ruleType]];
        [aryPredicates addObject:rule.predicate];
        NSLog(@"predicate = %@", rule.predicate);
        [aryColors addObject:[NSArchiver archivedDataWithRootObject:rule.color]];
    }
    NSLog(@"saving %u rules", [rules count]);
    [super saveDefaultValue:aryFields forKey:RULE_FIELDS];
    [super saveDefaultValue:aryColors forKey:RULE_COLORS];
    [super saveDefaultValue:aryCompares forKey:RULE_COMPARES];
    [super saveDefaultValue:aryPredicates forKey:RULE_PREDS];
    [super saveDefaultValue:aryTypes forKey:RULE_TYPES];
}

-(void) saveDefaults{
	[super saveDefaults];
	[super saveDefaultValue:mailMailboxName forKey:MAILBOX];
	[super saveDefaultValue:accountName forKey:ACCOUNT];
	[super saveDefaultValue:[NSNumber numberWithDouble:refreshInterval *60] forKey:REFRESH];
	[super saveDefaultValue:[NSNumber numberWithDouble:displayWindow*60*60] forKey:DISPLAYWIN ];
	[super saveDefaultValue:[NSNumber numberWithBool:useDisplayWindow] forKey:USEDISPWIN ];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [self saveRules];
}


- (IBAction) colorPicked: (id) sender
{
    NSLog(@"color picked"); 
}

- (IBAction) colorEdit: (id) sender
{
    NSColorPanel *cp = [NSColorPanel sharedColorPanel];
    [cp setAction:@selector(colorPicked:)];
    [cp setTarget:self];
    [cp makeKeyAndOrderFront:self];
}

-(void) loadView
{
	[super loadView];
	
	[accountField setStringValue:accountName == nil ? @"" : accountName];
	[mailboxField setStringValue:mailMailboxName == nil ? @"" : mailMailboxName];
	[refreshIntervalField setDoubleValue:refreshInterval/60];
	[refreshIntervalStepper setDoubleValue:refreshInterval];
	[displayWindowField setDoubleValue:displayWindow];
	[displayWindowStepper setDoubleValue:displayWindow];
	[useDisplayWindowButton setIntValue:useDisplayWindow];
	[displayWindowField setEnabled:useDisplayWindow];
	[displayWindowStepper setEnabled:useDisplayWindow];
    NSTableColumn *col = [rulesTable.tableColumns objectAtIndex:0];
    ColorWellCell *cw = [ColorWellCell new];
    [cw setAction: @selector(colorEdit:)];
    [cw setTarget:self];
    [cw setEnabled:YES];
    [col setDataCell:[ColorWellCell new]];
    NSTableColumn *orig = [rulesTable.tableColumns objectAtIndex:4];
    VariableTableColumn *vtc = [[VariableTableColumn alloc]initWithColumn:orig];
    [vtc setTable:rulesTable];
    [vtc setKeyColumn:[rulesTable.tableColumns objectAtIndex:2]];
    [vtc setDataSource:rulesData];
    [vtc setWidth:159.0];
    [rulesTable removeTableColumn:orig];
    [rulesTable addTableColumn:vtc];
}

- (IBAction) clickUseDisplayWindow: (id) sender
{
	useDisplayWindow = useDisplayWindowButton.intValue;
	[displayWindowField setEnabled:useDisplayWindow];
	[displayWindowStepper setEnabled:useDisplayWindow];	
}

- (void) loadRules
{
    NSArray *colors = [Utility loadColorsForKey:[super myKeyForKey:RULE_COLORS]];
    NSArray *predicates = [super loadDefaultForKey:RULE_PREDS];
    NSArray *types = [super loadDefaultForKey:RULE_TYPES];
    NSArray *compares = [super loadDefaultForKey:RULE_COMPARES];
    NSArray *fields = [super loadDefaultForKey:RULE_FIELDS];
    
    rules = [[NSMutableArray alloc] initWithArray: [FilterRule loadFiltersWithTypes:types fields:fields compares:compares predicates:predicates colors:colors]];

	//[NSMutableArray arrayWithArray: 
	// [FilterRule loadFiltersWithTypes:types fields:fields compares:compares predicates:predicates colors:colors]];
}

-(void) loadDefaults
{
	[super loadDefaults];
	accountName = [super loadDefaultForKey:ACCOUNT];
	mailMailboxName = [super loadDefaultForKey:MAILBOX];
	refreshInterval = ((NSNumber*)[super loadDefaultForKey:REFRESH]).doubleValue/60;
	displayWindow = ((NSNumber*)[super loadDefaultForKey:DISPLAYWIN]).doubleValue/ (60 * 60);
	useDisplayWindow = ((NSNumber*)[super loadDefaultForKey:USEDISPWIN	]).intValue;
    [self loadRules];
}

-(void) clearDefaults{
	[super clearDefaults];
	[super clearDefaultValue:accountName forKey:ACCOUNT];
	[super clearDefaultValue:mailMailboxName forKey:MAILBOX];
	[super clearDefaultValue:nil forKey:DISPLAYWIN];
	[super clearDefaultValue:nil forKey:REFRESH ];
	[super clearDefaultValue:nil forKey:USEDISPWIN];
	[super clearDefaultValue:nil forKey:LASTCHECK];
	[super clearDefaultValue:nil forKey:RULE_PREDS];
	[super clearDefaultValue:nil forKey:RULE_COLORS];
	[super clearDefaultValue:nil forKey:RULE_COMPARES];
	[super clearDefaultValue:nil forKey:RULE_TYPES];
	[super clearDefaultValue:nil forKey:RULE_FIELDS];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) openMessage: (NSObject*) param
{
	NSDictionary *dict = (NSDictionary*) param;
	NSString *msgId = [dict objectForKey:@"id"];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	//	NSLog(@"will get all email later than %@", minTime);
	MailApplication *mailApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.mail"];
	if (mailApp) {

		for (MailAccount *mAcc in mailApp.accounts){
			if ([mAcc.name isEqualToString:accountName]){
				for(MailMailbox *box in mAcc.mailboxes){
					if ([box.name isEqualToString: mailMailboxName]) {
						for (MailMessage *msg in box.messages){
							if ([msg.messageId isEqualToString: msgId]){
								
								[msg open];
								BOOL res = [[NSWorkspace sharedWorkspace] launchApplication:@"Mail"];
								NSLog(@"launched = %d", res);
							}
														
						}
					}
				}
			}
		}
	}

	[pool drain];	
}
-(void) handleClick: (NSDictionary*) ctx
{
	NSDictionary *task = [NSDictionary dictionaryWithDictionary:(NSDictionary*) ctx];
	[NSThread detachNewThreadSelector: @selector(openMessage:)
							 toTarget:self
						   withObject:task];

}

- (void) clearRules
{

    [super clearDefaultValue:nil forKey:RULE_COLORS];
    [super clearDefaultValue:nil forKey:RULE_TYPES];
    [super clearDefaultValue:nil forKey:RULE_COMPARES];
    [super clearDefaultValue:nil forKey:RULE_PREDS];
    [super clearDefaultValue:nil forKey:RULE_FIELDS];
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
