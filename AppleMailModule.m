//
//  AppleMailModule.m
//  WorkPlayAway
//
//  Created by Charles on 2/16/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "AppleMailModule.h"
#import "Mail.h"
#import "MimeHandler.h"

#define MAILBOX @"mailMailbox"
#define ACCOUNT @"account"
#define REFRESH  @"refreshInterval"
#define DISPLAYWIN  @"displayWindow"
#define USEDISPWIN  @"useDisplayWindow"
#define LASTCHECK  @"lastCheck"

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
		//	minTagValue = [[NSNumber alloc]initWithInteger: 0];	

	}
	return self;
}

-(void) getUnread: (NSObject*) param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	unreadMail = [NSMutableArray new];
	NSDate *minTime = [NSDate distantPast];
	if (useDisplayWindow){
	//	NSLog(@"Now = %@", [NSDate date]);
		minTime = [[NSDate date] dateByAddingTimeInterval:-(displayWindow * 60 * 60)];
	//	NSLog(@"Disp window = %@", minTime);
	}
	// the window may be longer than the default window if we haven't checked the inbox in a while
	if (lastCheck){
		minTime = [lastCheck earlierDate:minTime];
	//	NSLog(@"Adjusted Disp window = %@", minTime);
}
//	NSLog(@"will get all email later than %@", minTime);
	MailApplication *mailApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.mail"];
	if (mailApp) {
		for (MailAccount *mAcc in mailApp.accounts){
			if ([mAcc.name isEqualToString:accountName]){
				for(MailMailbox *box in mAcc.mailboxes){
					if ([box.name isEqualToString: mailMailboxName]) {
						for (MailMessage *msg in box.messages){
							NSLog(@"from = %@ subj = %@",[mailApp extractAddressFrom:msg.sender], msg.subject);
							NSComparisonResult res = [msg.dateReceived compare:minTime];
							if (!(res == NSOrderedAscending)) {
								
								NSString *temp = msg.source;
								NSString *synopsis = [MimeHandler synopsis:temp];
					
								NSDictionary *params = 
								[NSDictionary dictionaryWithObjectsAndKeys:
								 name, REPORTER_MODULE,
								 synopsis, MAIL_SUMMARY,
								 [msg.subject copy], MAIL_SUBJECT,
								 [NSNumber numberWithBool:msg.readStatus], @"readStatus" , 
								 [mailApp extractNameFrom:msg.sender], MAIL_NAME,
								 [mailApp extractAddressFrom:msg.sender], MAIL_EMAIL,
								 [msg.dateReceived copy], MAIL_ARRIVAL_TIME,
								 [msg.dateSent copy], MAIL_SENT_TIME,
								 [msg.messageId copy], @"id",
								 nil ];
						//		NSLog(@"from = %@ subj = %@",[mailApp extractAddressFrom:msg.sender], msg.subject);
								[unreadMail addObject:params];
							}else {
								break;
							}

						}
					}
				}
			}
		}
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LASTCHECK];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSNotification *msg = [NSNotification notificationWithName:@"com.workplayaway.fetchDone" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:msg];
	[pool drain];	
}

-(void) refresh: (id<AlertHandler>) handler
{
	alertHandler = handler;
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fetchDone:)
												 name:@"com.workplayaway.fetchDone" 
											   object:nil];
	[NSThread detachNewThreadSelector: @selector(getUnread:)
							 toTarget:self
						   withObject:nil];
}

- (void) fetchDone: (NSNotification*) note
{
	for (NSDictionary *msg in unreadMail){
		Note *alert = [Note new];

		alert.moduleName = name;
		alert.title = [NSString stringWithFormat:@"From: %@",[msg objectForKey:MAIL_EMAIL]];;
		alert.message=[msg objectForKey:MAIL_SUMMARY];
		alert.sticky = NO;
		alert.urgent = NO;
		alert.params = msg;
        alert.clickable = YES;
			
		[alertHandler handleAlert:alert];
	}
	[BaseInstance sendDone:alertHandler module: name];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.workplayaway.fetchDone" object:nil];
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
												 name:@"com.workplayaway.validateDone" 
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
	NSNotification *msg = [NSNotification notificationWithName:@"com.workplayaway.validateDone" object:err];
	[[NSNotificationCenter defaultCenter] postNotification:msg];
	[pool drain];
}

- (void) validateDone: (NSNotification*) note
{
	[validationHandler performSelector:@selector(validationComplete:) 
								withObject:note.object];
}

-(void) saveDefaults{
	[super saveDefaults];
	[super saveDefaultValue:mailMailboxName forKey:MAILBOX];
	[super saveDefaultValue:accountName forKey:ACCOUNT];
	[super saveDefaultValue:[NSNumber numberWithDouble:refreshInterval *60] forKey:REFRESH];
	[super saveDefaultValue:[NSNumber numberWithDouble:displayWindow*60*60] forKey:DISPLAYWIN ];
	[super saveDefaultValue:[NSNumber numberWithInt:useDisplayWindow] forKey:USEDISPWIN];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) loadView
{
	[super loadView];
	
	[accountField setStringValue:accountName == nil ? @"" : accountName];
	[mailboxField setStringValue:mailMailboxName == nil ? @"" : mailMailboxName];
	[refreshIntervalField setDoubleValue:refreshInterval/ 60];
	[refreshIntervalStepper setDoubleValue:refreshInterval / 60];
	[displayWindowField setDoubleValue:displayWindow / 60 / 60];
	[displayWindowStepper setDoubleValue:displayWindow / 60 / 60];
	[useDisplayWindowButton setIntValue:useDisplayWindow];
	[displayWindowField setEnabled:useDisplayWindow];
	[displayWindowStepper setEnabled:useDisplayWindow];
	
}

- (IBAction) clickUseDisplayWindow: (id) sender
{
	useDisplayWindow = useDisplayWindowButton.intValue;
	[displayWindowField setEnabled:useDisplayWindow];
	[displayWindowStepper setEnabled:useDisplayWindow];	
}

-(void) loadDefaults
{
	[super loadDefaults];
	accountName = [super loadDefaultForKey:ACCOUNT];
	mailMailboxName = [super loadDefaultForKey:MAILBOX];
	refreshInterval = ((NSNumber*)[super loadDefaultForKey:REFRESH]).doubleValue/60;
	displayWindow = ((NSNumber*)[super loadDefaultForKey:DISPLAYWIN]).doubleValue/ (60 * 60);
	useDisplayWindow = ((NSNumber*)[super loadDefaultForKey:USEDISPWIN	]).intValue;
	lastCheck = (NSDate*)[super loadDefaultForKey:LASTCHECK];
}

-(void) clearDefaults{
	[super clearDefaults];
	[super clearDefaultValue:accountName forKey:ACCOUNT];
	[super clearDefaultValue:mailMailboxName forKey:MAILBOX];
	[super clearDefaultValue:nil forKey:DISPLAYWIN];
	[super clearDefaultValue:nil forKey:REFRESH ];
	[super clearDefaultValue:nil forKey:USEDISPWIN];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) openMessage: (NSObject*) param
{
	NSDictionary *dict = (NSDictionary*) param;
	NSString *msgId = [dict objectForKey:@"id"];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	unreadMail = [NSMutableArray new];
	NSDate *minTime = [NSDate distantPast];
	if (useDisplayWindow){
		//	NSLog(@"Now = %@", [NSDate date]);
		minTime = [[NSDate date] dateByAddingTimeInterval:-(displayWindow * 60 * 60)];
		//	NSLog(@"Disp window = %@", minTime);
	}
	// the window may be longer than the default window if we haven't checked the inbox in a while
	if (lastCheck){
		minTime = [lastCheck earlierDate:minTime];
		//	NSLog(@"Adjusted Disp window = %@", minTime);
	}
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
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LASTCHECK];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSNotification *msg = [NSNotification notificationWithName:@"com.workplayaway.fetchDone" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:msg];
	[pool drain];	
}
-(void) handleClick: (NSDictionary*) ctx
{
	NSDictionary *task = [NSDictionary dictionaryWithDictionary:(NSDictionary*) ctx];
	[NSThread detachNewThreadSelector: @selector(openMessage:)
							 toTarget:self
						   withObject:task];

}


@end
