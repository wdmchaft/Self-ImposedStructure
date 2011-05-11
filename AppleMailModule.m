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
#define RULECOUNT @"RuleCount"
#define RULE @"Rule"
#define RULE_COLORS @"RuleColors"
#define RULE_PREDS @"RulePredicates"
#define RULE_TYPES @"RuleTypes"
#define RULE_COMPARES @"RuleCompares"
#define RULE_FIELDS @"RuleFields"
#define CACHED_MAIL @"cachedMail"

@implementation AppleMailModule

@synthesize accountName;
@synthesize accountField;
@synthesize mailMailboxName;
@synthesize mailboxField;
@synthesize cachedMail;
@synthesize alertHandler;
@synthesize refreshIntervalField;
@synthesize refreshIntervalStepper;
@synthesize displayWindow;
@synthesize displayWindowField;
@synthesize displayWindowStepper;
@synthesize threadCache;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;
@dynamic summaryTitle;
@dynamic isWorkRelated;
@synthesize rulesData, rulesTable, removeRuleButton, addRuleButton, summaryMode;
@synthesize mailDateFmt;
@synthesize msgName;
@synthesize displayWindowFmt;
@synthesize lastRefresh;
@synthesize fetchCallback;
@synthesize errStr;

+ (void) initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt: 72],         @"cacheIntervalHours",
								 nil];
	
    [defaults registerDefaults:appDefaults];
}

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
		displayWindow = ((NSNumber*)[super loadDefaultForKey:DISPLAYWIN]).doubleValue;
		displayWindow = displayWindow / (60.0 * 60.0) ;
		if (!displayWindow){
			NSTimeInterval cacheHours = [[NSUserDefaults standardUserDefaults] doubleForKey:@"cacheIntervalHours"];
			displayWindow = cacheHours;
		}
	}
	return self;
}

- (NSDate*) lastCheck{
	NSDate *latestMsgDate = nil;
	if ([cachedMail count] > 0){
		latestMsgDate = [[cachedMail objectAtIndex:0] objectForKey:MAIL_ARRIVAL_TIME];
		//NSLog(@"last message subj = %@", [[cachedMail objectAtIndex:0] objectForKey: MAIL_SUBJECT]);
		//NSLog(@"last message arrived = %@", [[cachedMail objectAtIndex:0] objectForKey: MAIL_ARRIVAL_TIME]);
		latestMsgDate = [latestMsgDate dateByAddingTimeInterval:1.0]; // add one second
		return latestMsgDate;
	}
  
    NSUInteger cacheHours = [[NSUserDefaults standardUserDefaults] integerForKey:@"cacheIntervalHours"];
	NSTimeInterval cacheInterval = -1.0 * cacheHours * 60.0 * 60.0;
    latestMsgDate =  [[NSDate date] dateByAddingTimeInterval: cacheInterval];// nothing set - get msgs for cache interval
    return latestMsgDate;
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
    while ([test hasPrefix:@"RE:"] || [test hasPrefix:@"FW:"]){
        test = [test substringFromIndex:3];
        test = [self stripWhite:test];
    }
    return test;
}

- (NSString*) callbackName
{
    if (!msgName){
        NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
        msgName = [@"com.zer0gravitas.mailFetch" stringByAppendingString:[[NSNumber numberWithDouble:ti] stringValue]];
    }
	NSLog(@"callbackName = %@", msgName);
    return msgName;
}

- (NSString *) getScript
{

    NSDate *minTime = [self lastCheck];
    
    //NSLog(@"starting getNewest w/ received later than %@", minTime);    
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
	NSLog(@"%@", script);
    return script;
}

- (void) sendFetchWithScript: (NSString*) script
{
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	NSDictionary *params = nil;
	if (script) {
		NSLog(@"sending fetch with script");
		params = [NSDictionary dictionaryWithObjectsAndKeys:script, @"script",
							[self callbackName], @"callback", 
							nil];
	} else {
		NSLog(@"sending fetch without script");
		params = [NSDictionary dictionaryWithObjectsAndKeys: [self callbackName], @"callback", nil];
	}

	[dnc postNotificationName:@"com.zer0gravitas.applemaildaemon" object:nil userInfo:params];
}

- (void) messageFetched: (NSNotification*) notification
{
	NSDictionary *msg = [notification userInfo];
	errStr = [msg objectForKey:@"error"];
	if (errStr){		
		NSLog(@"got error %@", errStr);
		NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
		[dnc removeObserver:self name:[self callbackName] object:nil];
		[self performSelector:fetchCallback];
	}
	else {
		if ([msg count] == 0){
			NSLog(@"end of file");
			NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
			[dnc removeObserver:self name:[self callbackName] object:nil];
			[self performSelector:fetchCallback];
		} else {
			NSLog(@"got message");
			[newestMail addObject:[NSMutableDictionary dictionaryWithDictionary:msg]];
			[self sendFetchWithScript:NO];
		}
	}
}

#define MAILDAEMON @"AppleMailDaemon"
- (BOOL) launchDaemonIfNeeded
{
	NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:MAILDAEMON];
	BOOL started = [[defaults objectForKey:@"running"] integerValue];
	if (!started) {
		NSString *supportDir = [Utility applicationSupportDirectory];
		NSString *monitorPath = [NSString stringWithFormat:@"%@/Plugins/%@",supportDir, MAILDAEMON];
		
		//	NSString *monitorPath = [NSString stringWithFormat:@"%@/%@.app/Contents/MacOS/%@",@"/Applications/", 
		//							 ICALDAEMON,ICALDAEMON];
		NSLog(@"monitorPath = %@", monitorPath);
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self 
															selector:@selector(getNewest)
																name:@"com.zer0gravitas.applemaildaemon.started" 
															  object:nil];	
		NSTask *task = [NSTask launchedTaskWithLaunchPath:monitorPath arguments:[NSArray new]];
		if (!task){
			NSLog(@"error launching %@", MAILDAEMON);
			return NO;
		}
		return YES;
	}
	return NO;
}

-(void) getNewest
{
	if ([self launchDaemonIfNeeded] == YES) {
		return;
	}
	lastRefresh = [NSDate date];
    NSString *script = [self getScript];
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc addObserver:self 
			selector:@selector(messageFetched:)
				name:[self callbackName] 
			  object:nil];
	[self sendFetchWithScript:script];
}

-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary
{

	alertHandler = handler;
    summaryMode = summary;
    if (!newestMail) {
        newestMail = [NSMutableArray new];
    }
    if (!cachedMail){
        cachedMail = [NSMutableArray new];
    }
    [newestMail removeAllObjects];
    //NSLog(@"msg = %@",[self msgName]);
//	if (lastRefresh && ([lastRefresh timeIntervalSinceNow] > -120.0)) {
//		// just return the cache
//		[self fetchDone:nil];
//	}
    fetchCallback = @selector(fetchDone);
	[self getNewest];
}

/**
 * make threads for messages with equivalent subject headers
 */
- (void) processThreads
{
    NSMutableArray *newUnread = [NSMutableArray arrayWithCapacity:[cachedMail count]];
    NSMutableDictionary *threadDict = [NSMutableDictionary dictionaryWithCapacity:[cachedMail count]];
    // now run through the mail and look for threads 
    for (NSMutableDictionary *msg in cachedMail){
        NSString *subj = [self stripRe:[msg objectForKey:MAIL_SUBJECT]];
        
        NSMutableDictionary *match = [threadDict objectForKey:subj];
        if (match){
            NSMutableArray *thread = [match objectForKey:@"THREAD"];
            if (!thread){
                thread = [NSMutableArray new];
                [match setObject:thread forKey:@"THREAD"];
            }
            [thread addObject:msg];
        }
        else {
            [threadDict setObject:msg forKey:subj];
            [newUnread addObject:msg];
        }
    }
    /** replace unreadMail with threadedUnreadMail **/
    cachedMail = newUnread;	
}

// there are two caches -- a sequential cache called "cachedMail"
// and a cache by subject/thread called "threadCache"
- (void) mergeToCache
{
	// process the new mail from oldest to newest
	// for each message try to find a thread for it
	// if you find a thread then put this item on top of it
	
	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:MAIL_ARRIVAL_TIME
															 ascending:NO
															  selector:@selector(compare:)];
	NSArray *descArray = [[NSArray alloc] initWithObjects:dateSort,nil];
	[newestMail sortUsingDescriptors:descArray];
	
	for (int msgIdx = [newestMail count] - 1; msgIdx > -1; msgIdx--){
		NSMutableDictionary *msg = [newestMail objectAtIndex:msgIdx];
		NSString *subj = [self stripRe:[msg objectForKey:MAIL_SUBJECT]];

		// look for a thread for this guy
		NSMutableDictionary *match = [threadCache objectForKey:subj];
        if (match){
            NSMutableArray *thread = [match objectForKey:@"THREAD"];
			// there is no thread yet so create one hanging from this guy
            if (!thread){
                thread = [[NSMutableArray alloc] init];
                [msg setObject:thread forKey:@"THREAD"];
				[thread addObject:match];
            }
			// there is already an existing thread hanging from a message
			// move that thread to this message
			// remove the reference to the thread from the message where we found it
			// put that older message at the top of the thread
			else {
				[msg setObject:thread forKey:@"THREAD"];
				[match removeObjectForKey:@"THREAD"];
				[thread insertObject:match atIndex:0];
			}
			// there is an entry in the threadCache to be replaced
			[threadCache removeObjectForKey:subj];
			[cachedMail removeObject:match];
  }
		// with or without a new thread push this new message to the front of the sequential cache
		// and add it to the thread cache
		if (!cachedMail) {
			cachedMail = [NSMutableArray new];
		} 
		if (!threadCache){
			threadCache = [NSMutableDictionary new];
		}
		[cachedMail insertObject:msg atIndex:0];
		[threadCache setObject:msg forKey:subj];
	}
}

- (void) saveCache
{
	// we can not easily save a color into defaults so just blow it off 
	// also the threads don't seem to restore nicely so remove them
	
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[cachedMail count]];
	
	for (NSMutableDictionary *item in cachedMail){
		//NSLog(@"item subj = %@", [item objectForKey:MAIL_SUBJECT]);
		NSArray *thread = [item objectForKey:@"THREAD"];
		if (thread){
			//NSLog(@"has thread");
			for (NSMutableDictionary *titem in thread){
				//NSLog(@"thread item subj = %@", [titem objectForKey:MAIL_SUBJECT]);
				[titem removeObjectForKey:@"color"];
				[temp addObject: titem];
			}
			NSMutableDictionary *tdict = [NSMutableDictionary dictionaryWithDictionary:item];
			[tdict removeObjectForKey:@"color"];
			[tdict	removeObjectForKey:@"THREAD"];
			[temp addObject:tdict];
		} else {
			if ([item objectForKey:@"color"] != nil){
				[item removeObjectForKey:@"color"];
			}
			[temp addObject:item];

		}
	}

	// lastly - use this as an opportunity to remove entries that are too old

	NSMutableArray *temp2 = [NSMutableArray arrayWithCapacity:[temp count]];
	NSDate *now = [NSDate date];
	for (NSMutableDictionary *item in temp){
		NSDate *rcvDate = [item objectForKey:MAIL_ARRIVAL_TIME];
		NSTimeInterval age = [now timeIntervalSinceDate:rcvDate];
		if (age < (displayWindow * 60 * 60)){
			[temp2 addObject:item];
		}
	}
	[super saveDefaultValue:temp2 forKey:CACHED_MAIL];
}

- (void)  cacheFetched
{
	if (errStr != nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Problem validating"
										 defaultButton:nil 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"Cache fetch failed with eror [%@]  You can try again",errStr];
		[alert runModal];		
		return;
	}
	
	[self mergeToCache];
	[self saveCache];
   // [super saveDefaultValue:cachedMail forKey:CACHED_MAIL];
	NSNotification *msg = [NSNotification notificationWithName:@"com.zer0gravitas.validateDone" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:msg];
}

- (void) fetchDone
{
// 	if (note.object != nil) {
//        //NSLog(@"%@ fetch cancelled or timed out",name);
//		return;
//	}
    if (errStr){
        //NSLog(@"%@ got Error! %@ \n trying again", name, eventErr);
		[self getNewest];
	}
    else {
		[self mergeToCache];
		[self saveCache];
	//	[super saveDefaultValue:cachedMail forKey:CACHED_MAIL];
//		[self processThreads];
        NSDate *minTime = [NSDate date];
		//NSLog(@"(minTime = %@", minTime);

        if (summaryMode){
			NSTimeInterval window = -(displayWindow * 60.0 * 60.0);
			//NSLog(@"time interval = %f secs", window);
            minTime = [minTime dateByAddingTimeInterval:window];
			NSAssert(minTime != nil, @"minTime is nil!");
			//NSLog(@"(minTime = %@", minTime);
            // the window may be longer than the default window if we haven't checked the inbox in a while
            minTime = [[self lastCheck] earlierDate:minTime];
        } else if (!summaryMode){
            minTime = [self lastCheck];
        }
	
	
        NSMutableArray *mailToSend = [NSMutableArray arrayWithCapacity:[cachedMail count]];
        for (NSMutableDictionary *msg in cachedMail){
            NSColor *ruleColor = nil;
            
            NSDate *msgRecDate = [msg objectForKey:MAIL_ARRIVAL_TIME];
			//NSLog(@"rcv date = %@ - subj [%@]", msgRecDate, [msg objectForKey:MAIL_SUBJECT]);
            NSComparisonResult compRes = [msgRecDate compare:minTime];
//			NSString *subj = [msg objectForKey:MAIL_SUBJECT];
//			NSString *time = [msg objectForKey:MAIL_ARRIVAL_TIME];
			if (compRes == NSOrderedAscending){
                continue;
            }
            
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
	NSLog(@"apple mail: sending refresh done");
	[BaseInstance sendDone:alertHandler module: name];	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[self msgName] object:nil];
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	displayWindow = [displayWindowField doubleValue];
	
	// if the mailbox and account are still the same then don't bother loading the cache
	
	if ([[mailboxField stringValue] isEqualToString:mailMailboxName] &&
		[[accountField stringValue] isEqualToString:accountName]){
		[self validateDone:nil];
	}
	else {
		accountName = [accountField stringValue];
		mailMailboxName = [mailboxField stringValue];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(validateDone:)
													 name:@"com.zer0gravitas.validateDone" 
												   object:nil];
		[NSThread detachNewThreadSelector: @selector(doValidate:)
								 toTarget:self
							   withObject:nil];
	}
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
    if (err != nil) {
        NSNotification *msg = [NSNotification notificationWithName:@"com.zer0gravitas.validateDone" object:err];
        [[NSNotificationCenter defaultCenter] postNotification:msg];
		return;
    }
	fetchCallback = @selector(cacheFetched);
	[self setSummaryMode:YES];
    [self getNewest];
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
        //NSLog(@"predicate = %@", rule.predicate);
        [aryColors addObject:[NSArchiver archivedDataWithRootObject:rule.color]];
    }
    //NSLog(@"saving %u rules", [rules count]);
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
	[[NSUserDefaults standardUserDefaults] synchronize];
    [self saveRules];
}


- (IBAction) colorPicked: (id) sender
{
    //NSLog(@"color picked"); 
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
    NSUInteger cacheHours = [[NSUserDefaults standardUserDefaults] integerForKey:@"cacheIntervalHours"];
    [displayWindowStepper setMaxValue:cacheHours];
    [displayWindowFmt setMaximum:[NSNumber numberWithInt:cacheHours]];
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
    if (!displayWindow){
        NSTimeInterval cacheHours = [[NSUserDefaults standardUserDefaults] doubleForKey:@"cacheIntervalHours"];
       displayWindow = cacheHours;
    }
	NSArray *temp = [super loadDefaultForKey:CACHED_MAIL];
	newestMail = [[NSMutableArray alloc]initWithCapacity:[temp count]];
	for (NSDictionary *msg in temp){
		NSMutableDictionary *msgM = [[NSMutableDictionary alloc]initWithDictionary:msg];
		if ([msgM objectForKey:@"THREAD"]){
			[msgM removeObjectForKey:@"THREAD"];
		}
		[newestMail addObject:msgM];
	}
	[self mergeToCache];
    [self loadRules];
}

-(void) clearDefaults{
	[super clearDefaults];
	[super clearDefaultValue:accountName forKey:ACCOUNT];
	[super clearDefaultValue:mailMailboxName forKey:MAILBOX];
	[super clearDefaultValue:nil forKey:DISPLAYWIN];
	[super clearDefaultValue:nil forKey:REFRESH ];
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
	//NSLog(@"msgId = %@", msgId);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	//	//NSLog(@"will get all email later than %@", minTime);
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
								//NSLog(@"launched = %d", res);
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
    
	//   //NSLog(@"cell idx  = %d", idx);
	//   //NSLog(@"cell title = %@", [pop titleOfSelectedItem]);
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

- (void) changeState: (WPAStateType) state
{
	if (state == WPASTATE_OFF){
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.zer0gravitas.applemaildaemon.quit" object:nil];
	}
}
@end
