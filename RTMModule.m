//
//  RTMModule.m
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//
#define EMAIL @"Email"
#define PASSWORD @"Password"
#define REFRESH @"Refresh"
#define LISTNAME @"ListName"
#define TOKEN  @"Token"
#define LISTID @"ListId"

#import "Secret.h"
#import "RTMModule.h"
#import "Note.h"
#import "RequestREST.h"
#import "ListHandler.h"
#import "ListsHandler.h"
#import "TokenHandler.h"
#import "RefreshHandler.h"
#import "RefreshListHandler.h"
#import "TaskDialogController.h"
#import "Utility.h"
#import "CompleteProcessHandler.h"

@implementation RTMModule 

@synthesize tokenStr; 
@synthesize userStr; 
@synthesize passwordStr; 
@synthesize frobStr; 
@synthesize listNameStr;
@synthesize idMapping;
@synthesize tasksDict;
@synthesize tasksList;
@synthesize userText;
@synthesize passwordText;
@synthesize listsCombo;
@synthesize refreshStepper;
@synthesize refreshText;
@synthesize refreshLabel;
@synthesize stepperLabel;
@synthesize comboLabel;
@synthesize authButton;
@synthesize progInd;
@synthesize firstClick;
@synthesize listIdStr;
@synthesize timelineStr;
@synthesize alarmSet;
@synthesize handler;
@synthesize lastError;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;

/**
 Responding to refresh tracking items
 */
- (void) taskRefreshDone
{
	NSNotification *notice = [NSNotification notificationWithName:@"org.ottoject.tasks" object:nil];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotification:notice];
}

- (void) listDone 
{
	int taskCount = [tasksList count];
	int count = 0;
	for (NSString *taskName in tasksList){
		NSDictionary *tc = [[NSDictionary alloc]initWithDictionary:
							[tasksDict objectForKey:taskName] copyItems:YES];
		Note *alert = [[Note alloc]init];
		alert.moduleName = name;
		alert.title =name;
		alert.message=taskName;
		alert.params = tc;
		alert.lastAlert = ++count == taskCount;
		[handler handleAlert:alert];
	}
	[self taskRefreshDone];
}


-(void) runListReqWithHandler: (ResponseRESTHandler*)respHndler
{
	RequestREST *rr = [[RequestREST alloc]init];

	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.tasks.getList", @"method",
									listIdStr,@"list_id",
									@"xml", @"format",
									@"status:incomplete:", @"filter",
									APIKEY, @"api_key", nil];
	
	[progInd startAnimation:self];
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET 
										 andParams:params]
				andHandler: respHndler];
	[rr release];
	
}

-(void) updateList
{
	RefreshListHandler *refHandler = [[[RefreshListHandler alloc]initWithContext:self andDelegate:self] autorelease];
	[self runListReqWithHandler:refHandler];
}

-(void) startRefresh: (NSTimer*) theTimer
{
	RefreshHandler *refHandler = [[[RefreshHandler alloc]initWithContext:self andDelegate:self] autorelease];
	[self runListReqWithHandler:refHandler];
}

- (void) processAlertsWithAlarms: (BOOL) setAlarms
{

	for(int i = 0; i < [tasksList count]; i++){
		NSString *key = [tasksList objectAtIndex:i];
		NSDictionary *item = nil;
		item = [tasksDict objectForKey: key];		
		NSDate *date = [item objectForKey:@"due_time"];
		NSComparisonResult cr = NSOrderedSame; // this will *stay* if there is no date
		if (date){
			cr = [date compare:[NSDate date]];
		}
		Note *alert = [[Note alloc]init];
		alert.moduleName = name;
		NSString *dateStr = date ? [Utility timeStrFor:date] : @"";
		NSString *alertTitle = [listNameStr copy];
		if (cr == NSOrderedDescending) {
			alertTitle = [alertTitle stringByAppendingFormat:@"[Task Due: %@]",dateStr];
		} else if (cr == NSOrderedAscending) {
			alertTitle = [alertTitle stringByAppendingFormat:@"[Task OverDue: %@]",dateStr];
		}
		alert.title = alertTitle;
		alert.clickable = YES;
		
		alert.message=[item objectForKey:@"name"];
		alert.params = item;
		[handler handleAlert:alert];
		
		if (cr == NSOrderedDescending && setAlarms == YES) {
			NSTimeInterval dueInterval = [date timeIntervalSinceNow];
			if (alarmSet == nil){
				alarmSet = [NSMutableDictionary new];
			}
			Note *alarm = [alert copy];
			alarm.title =[listNameStr stringByAppendingString:@" [Task Due Now]"];
			alarm.urgent = YES;
			alarm.sticky = YES;
			NSString *key = [NSString stringWithFormat:@"%@%@",
							 [date description],
							 [item objectForKey:@"name"]];
			// if we do not already have an alarm set -- set it
			if ([alarmSet objectForKey:key] == nil){
				NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:dueInterval
																  target:self 
																selector:@selector(handleWarningAlarm:)
																userInfo:alarm
																 repeats:NO]; 
				
				[alarmSet setObject:timer forKey:key];	
			}
		}
	}		
	[BaseInstance sendDone: handler module:name];
}


- (void) refreshDone
{
	[self taskRefreshDone];
	[self processAlertsWithAlarms:YES];
}

- (void) handleWarningAlarm: (NSTimer*) theTimer
{
	Note *alert = (Note*)[theTimer userInfo];
	[handler handleAlert:alert];
}

- (void) refresh: (<AlertHandler>) alertHandler
{
	self.handler = alertHandler;
	[self startRefresh: nil];
}

- (void) stateChange: (WPAStateType) newState
{
	if (newState == WPASTATE_OFF){
		[self stop];
	}
}

-(void) stop
{
	if (alarmSet){
		NSArray *keys = [alarmSet allKeys];
		int count = [keys count];
		while (count > 0) {
			NSString *key = [keys objectAtIndex: count - 1];
			NSTimer *timer = [alarmSet objectForKey:key];
			[timer invalidate];
			[alarmSet removeObjectForKey:key];
			count --;
		}
		alarmSet = nil;
	}
}

-(void) handleClick: (NSDictionary*) ctx
{
	NSDictionary *task = [NSDictionary dictionaryWithDictionary:(NSDictionary*) ctx];
	NSString *name = [task objectForKey:@"name"];
	TaskDialogController *dialogCtrl= [[TaskDialogController alloc] 
									   initWithWindowNibName:@"TaskDialog" 
									   andContext:self
														andParams:ctx ];
	dialogCtrl.context = self;
	[dialogCtrl showWindow:self];
	
	NSLog(@"name: %@",name, nil);
}

- (IBAction) clickRefreshStepper: (id) sender
{
	refreshText.intValue = refreshStepper.intValue;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		name =@"RTM Module";
		notificationName = @"Task Alert";
		notificationTitle = @"Task Msg";
		category = CATEGORY_TASKS;
		summaryTitle = @"Current Tasks";
		refreshInterval = 15 * 60;
		[refreshText setIntValue:refreshInterval / 60];	
	}
	return self;
}

-(void) loadView
{
	[super loadView];
	firstClick = YES;
	[listsCombo setHidden:YES];
	[listsCombo removeAllItems];
	[refreshText setHidden:YES];	
	[refreshLabel setHidden:YES];	
	[comboLabel setHidden:YES];	
	[refreshStepper setHidden:YES];	
	[stepperLabel setHidden:YES];	
	[progInd setHidden:YES];
	[userText setStringValue:userStr == nil ? @"" : userStr];
	[passwordText setStringValue:passwordStr == nil ? @"" : passwordStr];
	[refreshText setIntValue: refreshInterval / 60];
	if (tokenStr == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Not Authorized" 
										 defaultButton:nil alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"To authorize this plugin for RTM enter your rememberthemilk user and password then click the authorize button.\nA browser session will open for you to grant permission to this app.  Once you have completed this return to this dialog and click \"Authorized\""];
		[alert runModal];	
	}
	else {
		[progInd startAnimation:self];
		[progInd setHidden:NO];
		[self getLists];
	}
}

-(void) loadDefaults
{
	[super loadDefaults];
	tokenStr = [super loadDefaultForKey:TOKEN];
	passwordStr = [super loadDefaultForKey:PASSWORD];
	userStr = [super loadDefaultForKey:EMAIL];
	listNameStr = [super loadDefaultForKey:LISTNAME];
	listIdStr = [super loadDefaultForKey:LISTID];
	NSNumber *temp =  [super loadDefaultForKey:REFRESH];
	if (temp) {
		refreshInterval = [temp intValue];
	}
}


-(void) clearDefaults
{
	[super clearDefaults];
	[super clearDefaultValue:userStr forKey:EMAIL];
	[super clearDefaultValue:passwordStr forKey:PASSWORD];
	[super clearDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super clearDefaultValue:listNameStr forKey:LISTNAME];
	[super clearDefaultValue: listIdStr forKey:LISTID];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) saveDefaults
{
	[super saveDefaults];
	[super saveDefaultValue:tokenStr forKey:TOKEN];
	[super saveDefaultValue:userStr forKey:EMAIL];
	[super saveDefaultValue:passwordStr forKey:PASSWORD];
	[super saveDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super saveDefaultValue:listNameStr forKey:LISTNAME];
	[super saveDefaultValue: listIdStr forKey:LISTID];
	[[NSUserDefaults standardUserDefaults] synchronize];		
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	userStr = userText.stringValue;
	passwordStr = passwordText.stringValue;
	refreshInterval = (refreshText.intValue * 60);

	listNameStr = [listsCombo titleOfSelectedItem];
	listIdStr = [idMapping objectForKey:listNameStr];
	[validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	}

- (void) clickAuthButton: (id) sender
{
	if (firstClick == YES){
		RequestREST *rr = [[RequestREST alloc]init];
		NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
										@"rtm.auth.getFrob", @"method",
										@"xml", @"format",
										APIKEY, @"api_key", nil];
		
		FrobHandler *frobHandler = (FrobHandler*)[[FrobHandler alloc]initWithContext:self andDelegate:self];
		[progInd startAnimation:self];
		//NSURLConnection *obj = [rr sendRequest:@"rtm.auth.getFrob" 
		[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
										   usingSecret: SECRET  
											 andParams:params]
					andHandler: frobHandler];
		[rr release];		
		[progInd setHidden:NO];
		[progInd startAnimation:self];
		firstClick = NO;
	}
	else {
		RequestREST *rr = [[RequestREST alloc]init];
		NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
										frobStr, @"frob",
										@"rtm.auth.getToken", @"method",
										@"xml", @"format",
										APIKEY, @"api_key", nil];
		
		TokenHandler *tokHandler = (TokenHandler*)
		[[TokenHandler alloc]initWithContext:self andDelegate:self]; 
		[progInd startAnimation:self];
		[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
										   usingSecret:SECRET
											 andParams:params]
					andHandler: tokHandler];
		[rr release];	
		[progInd setHidden:NO];
	}
}


-(void) frobDone {
	[progInd stopAnimation:self];
	[progInd setHidden:YES];
	if (frobStr == nil){
		if (tokenStr == nil){
			NSString *errDetail = lastError != nil ? [NSString stringWithFormat:@" (%@)",lastError] : @"";
			NSString *msgText = [NSString stringWithFormat:@"Authorization Error%@",errDetail];
			NSAlert *alert = [NSAlert alertWithMessageText:msgText
											 defaultButton:nil 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:@"Hmmm I could not get a frob while authorizing this application.  Lets try authorizing again"];
			[alert runModal];
			firstClick = YES;
			authButton.title =@"Authorize";
			[progInd setHidden: YES];
			lastError = nil;
		}	
	}
	else {
		RequestREST *rr = [[RequestREST alloc]init];
		NSString *urlStr = [rr createURLWithFamily: @"auth" 
									   usingSecret: SECRET
										 andParams:
							[NSDictionary dictionaryWithObjectsAndKeys:
							 APIKEY, @"api_key",
							 @"delete", @"perms",
							 frobStr, @"frob", 
							 nil]];
		NSLog(@"auth url:%@",urlStr);
		NSURL *url = [NSURL URLWithString:urlStr];
		[[NSWorkspace sharedWorkspace] openURL:url];
		authButton.title =@"Authorized";
	}
}

-(void) tokenDone {
	[progInd stopAnimation:self];
	
	if (tokenStr == nil){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization Error" 
										 defaultButton:nil 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"Hmmm I could not get a token whle authorizing this application.  Lets try authorizing again"];
		[alert runModal];
		firstClick = YES;
		authButton.title =@"Authorize";
		[progInd setHidden: YES];
	}
	else {
		[super saveDefaultValue:tokenStr forKey:TOKEN];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"token: %@",tokenStr);
		// we have a token - now get the valid RTM task lists
		[self getLists];
	}
}

-(void) getLists
{
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									tokenStr, @"auth_token",
									@"rtm.lists.getList", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	ListsHandler *listsHandler = (ListsHandler*)[[ListsHandler alloc]initWithContext:self andDelegate:self]; 
	[progInd startAnimation:self];
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET 
										 andParams:params]
				andHandler: listsHandler];
	[rr release];
}


-(void) listsDone 
{
	[progInd stopAnimation:self];
	[progInd setHidden: YES];	
	if (idMapping == nil){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Error getting task lists" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Hmmm I could not get a token to authorizing this application.  Lets try authorizing again"];
		firstClick = YES;
		authButton.title =@"Authorize";
		[progInd setHidden: NO];
		[alert runModal];
	}
	else {
		NSArray *keys = [idMapping allKeys];
		for (int i = 0; i < [keys count];i++){
			NSString *item = [keys objectAtIndex:i];
			[listsCombo addItemWithTitle:item];
		}
		if (listNameStr != nil){
			[listsCombo selectItemWithTitle:listNameStr];
		} 
		else{
			listNameStr = [keys objectAtIndex:0];
		}
		[listsCombo setHidden: NO];
//		[listsCombo selectItem:[keys objectAtIndex:0]];
		[refreshText setHidden:NO];
		[refreshStepper setHidden:NO];
		[refreshLabel setHidden:NO];
		[stepperLabel setHidden:NO];		
	}
}

- (void) clickList: (id) sender
{
	listNameStr = listsCombo.stringValue;
}

-(NSArray*) getTasks;
{
	return tasksList;
}

-(void) refreshTasks
{
	[self updateList];
}

-(NSString*) projectForTask: (NSString *) task
{
	return [super description];
}

- (void) markComplete:(NSDictionary *)ctx completeHandler: (NSObject*) callback
{
	CompleteProcessHandler *cph = [[CompleteProcessHandler alloc]initWithContext: ctx 
																		   token: tokenStr 
																	 andDelegate: callback];
	[cph start];
}

@end
