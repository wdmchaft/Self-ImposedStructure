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

@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;



-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		name =@"Apple Mail Module";
		notificationName = @"Mail Alert";
		notificationTitle = @"Mail Msg";
		category = CATEGORY_EMAIL;
		//	minTagValue = [[NSNumber alloc]initWithInteger: 0];	

	}
	return self;
}

-(void) getUnread: (NSObject*) param
{
	unreadMail = [NSMutableArray new];
	MailApplication *mailApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.mail"];
	if (mailApp) {
		for (MailAccount *mAcc in mailApp.accounts){
			if ([mAcc.name isEqualToString:accountName]){
				for(MailMailbox *box in mAcc.mailboxes){
					if ([box.name isEqualToString: mailMailboxName]) {
						for (MailMessage *msg in box.messages){
							if (msg.readStatus == NO){
								NSString *temp = msg.source;
								NSString *synopsis = [MimeHandler synopsis:temp];
								NSRange sRange = [synopsis rangeOfString:@"--"];
								if (sRange.location != NSNotFound){
									NSLog(@"break");
								}
								NSDictionary *params = 
								[NSDictionary dictionaryWithObjectsAndKeys:
								 name, REPORTER_MODULE,
								 synopsis, MAIL_SUMMARY,
								 [msg.subject copy], MAIL_SUBJECT,
								 [mailApp extractNameFrom:msg.sender], MAIL_NAME,
								 [mailApp extractAddressFrom:msg.sender], MAIL_EMAIL,
								 [msg.dateReceived copy], MAIL_ARRIVAL_TIME,
								 [msg.dateSent copy], MAIL_SENT_TIME,
								 [msg.messageId copy], @"id",
								 nil ];
								NSLog(@"id = %@ subj = %@",msg.messageId, msg.subject);
								[unreadMail addObject:params];
							}
						}
					}
				}
			}
		}
	}
	NSNotification *msg = [NSNotification notificationWithName:@"com.workplayaway.fetchDone" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:msg];
	
}

-(void) refresh: (<AlertHandler>) handler
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

- (void) fetchDone: (NSNotification*) msg
{
	for (NSDictionary *msg in unreadMail){
		Note *alert = [Note new];

		alert.moduleName = name;
		alert.title = [NSString stringWithFormat:@"From: %@",[msg objectForKey:MAIL_EMAIL]];;
		alert.message=[msg objectForKey:MAIL_SUMMARY];
		alert.sticky = YES;
		alert.urgent = YES;
		alert.params = msg;
			
		[alertHandler handleAlert:alert];
	}
	[BaseInstance sendDone:alertHandler module: name];	
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	accountName = [accountField stringValue];
	mailMailboxName = [mailboxField stringValue];
	[validationHandler performSelector:@selector(validationComplete:) 
						withObject:nil];
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
	[refreshIntervalField setDoubleValue:refreshInterval];
	[refreshIntervalStepper setDoubleValue:refreshInterval];
	[displayWindowField setDoubleValue:displayWindow];
	[displayWindowStepper setDoubleValue:displayWindow];
	[useDisplayWindowButton setIntValue:useDisplayWindow];
}

-(void) loadDefaults
{
	[super loadDefaults];
	accountName = [super loadDefaultForKey:ACCOUNT];
	mailMailboxName = [super loadDefaultForKey:MAILBOX];
	refreshInterval = ((NSNumber*)[super loadDefaultForKey:REFRESH]).doubleValue/60;
	displayWindow = ((NSNumber*)[super loadDefaultForKey:DISPLAYWIN]).doubleValue/ (60 * 60);
	useDisplayWindow = ((NSNumber*)[super loadDefaultForKey:USEDISPWIN	]).intValue;
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

@end
