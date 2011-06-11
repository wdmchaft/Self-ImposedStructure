//
//  RTMModule.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//
#define EMAIL @"Email"
#define PASSWORD @"Password"
#define REFRESH @"Refresh"
#define LISTNAME @"ListName"
#define TOKEN  @"Token"
#define LISTID @"ListId"
#define TASKLIST @"taskList"
#define LOOKAHEAD @"lookAhead"

#import "Secret.h"
#import "RTMModule.h"
#import "WPAAlert.h"
#import "RequestREST.h"
#import "ListHandler.h"
#import "ListsHandler.h"
#import "TokenHandler.h"
#import "RefreshHandler.h"
#import "RefreshListHandler.h"
#import "TaskDialogController.h"
#import "Utility.h"
#import "CompleteProcessHandler.h"
#import "NewTaskHandler.h"
#import "RepeatRule.h"
#import "Queues.h"


@implementation RTMModule 

@synthesize userText;
@synthesize passwordText;
@synthesize listsCombo;
@synthesize refreshText;
@synthesize refreshLabel;
@synthesize stepperLabel;
@synthesize comboLabel;
@synthesize lookAheadLabel;
@synthesize lookAheadNote;
@synthesize authButton;
@synthesize progInd;
@synthesize alarmSet;
@synthesize handler;
@synthesize lastError;
@synthesize isWorkButton;
@synthesize isTrackedButton;
@synthesize lookAheadWindow;
@synthesize lookAheadText;
@dynamic enabled;
@dynamic category;
@dynamic name;
@dynamic summaryMode;
@dynamic tracked;
@dynamic isWorkRelated;
@dynamic completeQueue;

@synthesize protocol;

/**
 Responding to refresh tracking items
 */
- (void) taskRefreshDone
{
	[super saveDefaultValue:protocol.tasksList forKey:TASKLIST];
	NSNotification *notice = [NSNotification notificationWithName:@"com.zer0gravitas.tasks" object:self];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotification:notice];
}

- (void) listDone 
{
	[super saveDefaultValue:protocol.tasksList forKey:TASKLIST];
	if ([protocol.tasksList count] == 0){
	}
	for (NSDictionary *taskData in protocol.tasksList){
		WPAAlert *alert = [[WPAAlert alloc]init];
		alert.message=[taskData objectForKey: @"name"];
		//NSLog(@"taskName = %@", alert.message);
	//	NSDictionary *tc = [[NSDictionary alloc]initWithDictionary:
	//						[protocol.tasksDict objectForKey:taskName] copyItems:YES];
		alert.moduleName = name;
		alert.title =name;
		alert.message=[taskData objectForKey: @"name"];
		alert.params = taskData;
		alert.lastAlert =  NO;
		[handler handleAlert:alert];
	}
	if (summaryMode){
		NSLog(@"sending done");
		[BaseInstance sendDone:handler module:name];
	}
	[self taskRefreshDone];
}

- (NSDate*) windowDate
{
	NSDate *now = [NSDate date];
	int TIMECOMPS = NSDayCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	NSDateComponents *nowComps = [gregorian components:TIMECOMPS fromDate:now];
	nowComps.hour = 0;
	nowComps.minute = 0;
	nowComps.second = 0;
	nowComps.day += 1;
	return [gregorian dateFromComponents:nowComps];
}

- (NSDate *) dateForTomorrow 
{
	NSDate *now = [NSDate date];
	int TIMECOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
		NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	NSDateComponents *nowComps = [gregorian components:TIMECOMPS fromDate:now];
	nowComps.hour = 0;
	nowComps.minute = 0;
	nowComps.second = 0;
	nowComps.day += 1;  
	return [gregorian dateFromComponents:nowComps];
}

- (BOOL) repeatedTaskIgnorable: (NSDictionary*) msg
{
	// 
	// find tasks with recurrence rules for everyday (or weekly on specific days) 
	// if the due date is NOT today then return true 
	//
	// I do not want to be reminded today that I need to "feed the cat" tomorrow 
	//
	NSString *rptString = [msg objectForKey:@"rrule"];
	NSDate *dueDate = [msg objectForKey:@"due_time"];
	NSString *label = [msg objectForKey:@"name"];
	if (rptString && dueDate){
		RepeatRule *rRule = [[RepeatRule alloc]initFromString:rptString];
		FrequencyType freqType = [rRule frequency];
		int interval = [rRule interval];
		if (freqType == RepeatDaily || (freqType == RepeatWeekly && interval == 1)){
			NSDate* tomorrow = [self dateForTomorrow];
			NSComparisonResult res = [dueDate compare:tomorrow];
			NSLog(@"[%@] (%@) is %@ (%@)", label, dueDate, (res == NSOrderedDescending ? @"after" : @"not after"), tomorrow);	
			return res == NSOrderedDescending; // return true if the due date/time is after today
		}
	}
	return NO;
}


- (void) processAlertsWithAlarms: (BOOL) setAlarms
{
	NSDate *windowDate = [NSDate dateWithTimeIntervalSinceNow:lookAheadWindow];
	NSDate *nowDate = [NSDate date];
	NSArray *workList = [protocol.tasksList copy];
	for(NSMutableDictionary *item in workList){
		WPAAlert *alert = [[WPAAlert alloc]init];
		NSString *alertTitle = [protocol.listNameStr copy];
		alert.title = alertTitle;
		alert.clickable = YES;
		
		alert.message=[item objectForKey:@"name"];
		alert.params = item;
	
		NSDate *dueDate = [item objectForKey:@"due_time"];
		NSComparisonResult dueCheck = NSOrderedSame; // this will *stay* if there is no date
		NSComparisonResult windowCheck = NSOrderedSame; // this will *stay* if there is no date
		if (dueDate){
			dueCheck = [dueDate compare:nowDate];
			windowCheck = [dueDate compare:windowDate];
		}
		alert.moduleName = name;
		alert.isWork = isWorkRelated;
		if (alert.isWork)
		{
			[item setObject: [NSNumber numberWithBool:alert.isWork] forKey:@"work"];
		}
		NSString *dateStr = dueDate ? [Utility timeStrFor:dueDate] : @"";
		
		// check items which have due dates - they are either due in the future or past due or (unlikely) right now
		
		if (dueCheck == NSOrderedDescending) {
			
			// the task is due in the future don't show it (and remove it) if its out beyond our event horizon
			
			if (windowCheck == NSOrderedDescending) {
				[protocol.tasksList removeObject:item];
				continue;
			}
			alertTitle = [alertTitle stringByAppendingFormat:@"[Task Due: %@]",dateStr];
	
		} else if (dueCheck == NSOrderedAscending) {
			alertTitle = [alertTitle stringByAppendingFormat:@"[Task OverDue: %@]",dateStr];
		}
		else if (dueDate != nil) {
			// it has a due date which is *exactly equal* to the current time 
			//NSLog(@"wow - a task due right now:%@", alert.message);
			alertTitle = [alertTitle stringByAppendingString:@"[Task Due right now!!!]"];
		} else {
			// has no due date -- add a date in far future so task sorts to bottom of date sorted list
			[item setObject:[NSDate distantFuture] forKey:@"due_time"];
		}
		// strip out repeating tasks that are not necessary to show
		if ([self repeatedTaskIgnorable:item]) {
			continue;
		}

		[handler handleAlert:alert];
		
		if (dueCheck == NSOrderedDescending && setAlarms == YES) {
			NSTimeInterval dueInterval = [dueDate timeIntervalSinceNow];
			if (alarmSet == nil){
				alarmSet = [NSMutableDictionary new];
			}
			WPAAlert *alarm = [alert copy];
			alarm.title =[protocol.listNameStr stringByAppendingString:@" [Task Due Now]"];
			alarm.urgent = YES;
			alarm.sticky = YES;
			NSString *key = [NSString stringWithFormat:@"%@%@",
							 [dueDate description],
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
	[super saveDefaultValue:protocol.tasksList forKey:TASKLIST];
	[self taskRefreshDone];
	[self processAlertsWithAlarms:YES];
}

- (void) handleWarningAlarm: (NSTimer*) theTimer
{
	WPAAlert *alert = (WPAAlert*)[theTimer userInfo];
	[handler handleAlert:alert];
}

- (void) refresh: (id<AlertHandler>) alertHandler isSummary: (BOOL) summary useCache: (BOOL) cached
{
	// if we want to save time (and we have cache) -- just use it to return data
	if (cached && [[protocol tasksList] count] > 0){
		[self listDone];
		return;
	}
	self.handler = alertHandler;
	summaryMode = summary;
	[protocol startRefresh: self callback:@selector(refreshDone)];
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
//	NSDictionary *task = [NSDictionary dictionaryWithDictionary:(NSDictionary*) ctx];
//	NSString *clickName = [task objectForKey:@"name"];
	TaskDialogController *dialogCtrl= [[TaskDialogController alloc] 
									   initWithWindowNibName:@"TaskDialog" 
                                                andContext:protocol
                                                andParams:ctx ];
	
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	dialogCtrl.context = protocol;
	[dialogCtrl showWindow:self];
	
	//NSLog(@"name: %@",clickName, nil);
}

- (void) initGuts
{
	name =@"RTM Module";
	notificationName = @"Task Alert";
	notificationTitle = @"Task Msg";
	category = CATEGORY_TASKS;
	summaryTitle = @"Current Tasks";
	refreshInterval = 15 * 60;
	lookAheadWindow = 60 * 60 * 24 * 7.0;
	[refreshText setIntValue:refreshInterval / 60];	
	protocol = [RTMProtocol new];
	[protocol setModule:self];
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil params: _params
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil params:_params];
	if (self){
		[self initGuts];
	}
	return self;
}

-(id) init
{
	self = [super init];
	if (self){
		[self initGuts];
	}
	return self;
}

-(void) loadView
{
	[super loadView];
	[listsCombo setHidden:YES];
	[listsCombo removeAllItems];
	[refreshText setHidden:YES];	
	[refreshLabel setHidden:YES];	
	[comboLabel setHidden:YES];	
	[stepperLabel setHidden:YES];	
	[lookAheadLabel setHidden:YES];
	[lookAheadNote setHidden:YES];
	[progInd setHidden:YES];
	[userText setStringValue:protocol.userStr == nil ? @"" : protocol.userStr];
	[lookAheadText setIntValue: (lookAheadWindow / 24 / 60 / 60)];
	[lookAheadText setHidden:YES];
	[isWorkButton setHidden:YES];
	[isWorkButton setIntValue:isWorkRelated];
	[isTrackedButton setHidden:YES];
	[isTrackedButton setIntValue:tracked];
	[passwordText setStringValue:protocol.passwordStr == nil ? @"" : protocol.passwordStr];
	[refreshText setIntValue: refreshInterval / 60];
	if (protocol.tokenStr == nil) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Not Authorized" 
										 defaultButton:nil alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"To authorize this plugin for RTM enter your rememberthemilk user and password then click the authorize button.\nA browser session will open for you to grant permission to this app.  Once you have completed this return to this dialog and click \"Authorized\""];
		[alert runModal];	
	}
	else {
		[progInd startAnimation:self];
		[progInd setHidden:NO];
		[protocol getLists:self callback:@selector(listsDone)];
	}
}

-(void) loadDefaults
{
	[super loadDefaults];
	protocol.tokenStr = [super loadDefaultForKey:TOKEN];
	protocol.passwordStr = [super loadDefaultForKey:PASSWORD];
	protocol.userStr = [super loadDefaultForKey:EMAIL];
	protocol.listNameStr = [super loadDefaultForKey:LISTNAME];
	protocol.listIdStr = [super loadDefaultForKey:LISTID];
	NSNumber *temp =  [super loadDefaultForKey:REFRESH];
	if (temp) {
		refreshInterval = [temp intValue];
	}
	protocol.tasksList = [super loadDefaultForKey:TASKLIST];
	double lhtemp = [super loadDoubleDefaultForKey:LOOKAHEAD];
	if (lhtemp){
		lookAheadWindow = lhtemp;
	}
}

-(void) clearDefaults
{
	[super clearDefaultValue:protocol.userStr forKey:EMAIL];
	[super clearDefaultValue:protocol.passwordStr forKey:PASSWORD];
	[super clearDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super clearDefaultValue:protocol.listNameStr forKey:LISTNAME];
	[super clearDefaultValue: protocol.listIdStr forKey:LISTID];
	[super clearDefaultValue: [NSNumber numberWithDouble:lookAheadWindow] forKey:LOOKAHEAD];
	[[NSUserDefaults standardUserDefaults] synchronize];	
	[super clearDefaults];
}

-(void) saveDefaults
{
	[super saveDefaultValue:protocol.tokenStr forKey:TOKEN];
	[super saveDefaultValue:protocol.userStr forKey:EMAIL];
	[super saveDefaultValue:protocol.passwordStr forKey:PASSWORD];
	[super saveDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super saveDefaultValue:protocol.listNameStr forKey:LISTNAME];
	[super saveDefaultValue: protocol.listIdStr forKey:LISTID];
    [super saveDefaultValue:[NSNumber numberWithDouble:lookAheadWindow] forKey:LOOKAHEAD];
	[super saveDefaults];
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	[protocol setUserStr: userText.stringValue];
	[protocol setPasswordStr: passwordText.stringValue];
	refreshInterval = (refreshText.intValue * 60);
	lookAheadWindow = (lookAheadText.intValue * 60 * 60 * 24);
	isWorkRelated = [isWorkButton intValue];
	tracked = [isTrackedButton intValue];

	protocol.listNameStr = [listsCombo titleOfSelectedItem];
	protocol.listIdStr = [[self idMapping] objectForKey:protocol.listNameStr];
	[validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	
}

- (void) clickAuthButton: (id) sender
{

	// step 1 - get a Frob string in preparation for application authorization
	[protocol getFrob:self callback:@selector(frobDone)];
	[progInd setHidden:NO];
	[progInd startAnimation:self];

}

- (void) clickAuthorizedButton: (id) sender
{
	// step 3 - get a token which enables all further activity in RTM
	
	[protocol getToken:self callback:@selector(tokenDone)];
	[progInd setHidden:NO];
	[progInd startAnimation:self];

}

- (void) frobDone {
	[progInd stopAnimation:self];
	[progInd setHidden:YES];
	
	// somehow failed to get a frob
	
	if (protocol.frobStr == nil){
		if (protocol.tokenStr == nil){
			NSString *errDetail = lastError != nil ? [NSString stringWithFormat:@" (%@)",lastError] : @"";
			NSString *msgText = [NSString stringWithFormat:@"Authorization Error%@",errDetail];
			NSAlert *alert = [NSAlert alertWithMessageText:msgText
											 defaultButton:nil 
										   alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:@"Hmmm I could not get a frob while authorizing this application.  Lets try authorizing again"];
			[alert runModal];
			authButton.title =@"Authorize";
			[authButton setAction: @selector(clickAuthButton:)];
			[progInd setHidden: YES];
			lastError = nil;
		}	
	}
	else {
		
		// successful frob return -- 
		// now  (step 2) open the browser with the magic URL so the user can authorize the app
		
		NSString *urlStr = [protocol getAuthURL];
		//NSLog(@"auth url:%@",urlStr);
		NSURL *url = [NSURL URLWithString:urlStr];
		[[NSWorkspace sharedWorkspace] openURL:url];
		authButton.title =@"Authorized";
		[authButton setAction: @selector(clickAuthorizedButton:)];
	}
}

- (void) tokenDone {
	[progInd stopAnimation:self];
	
	if (protocol.tokenStr == nil){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization Error" 
										 defaultButton:nil 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"Hmmm I could not get a token whle authorizing this application.  Lets try authorizing again"];
		[alert runModal];
		authButton.title =@"Authorize";
		[progInd setHidden: YES];
		[progInd stopAnimation:self];
	}
	else {
		
		// token was acquired -- last thing to initialize the dialog is a to get tasklist names for the combo
		
		[super saveDefaultValue:protocol.tokenStr forKey:TOKEN];
		[[NSUserDefaults standardUserDefaults] synchronize];
		//NSLog(@"token: %@",protocol.tokenStr);
		// we have a token - now get the valid RTM task lists
		[progInd startAnimation:self];
		[progInd setHidden:NO];
		[protocol getLists:self callback:@selector(listsDone)];
	}
}


- (void) listsDone 
{
	[progInd stopAnimation:self];
	[progInd setHidden: YES];	
	if (protocol.idMapping == nil){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Error getting task lists" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Hmmm I could not get a token to authorizing this application.  Lets try authorizing again"];
		authButton.title =@"Authorize";
		[alert runModal];
	}
	else {
		
		// load the combo with all of the task lists
		
		NSArray *keys = [protocol.idMapping allKeys];
		for (int i = 0; i < [keys count];i++){
			NSString *item = [keys objectAtIndex:i];
			[listsCombo addItemWithTitle:item];
		}
		if (protocol.listNameStr != nil){
			[listsCombo selectItemWithTitle:protocol.listNameStr];
		} 
		else{
			protocol.listNameStr = [keys objectAtIndex:0];
		}
		[listsCombo setHidden: NO];
		[comboLabel setHidden:NO];
		[refreshText setHidden:NO];
		[refreshLabel setHidden:NO];
		[stepperLabel setHidden:NO];	
		[lookAheadText setHidden:NO];
		[lookAheadLabel setHidden:NO];
		[lookAheadNote setHidden:NO];
		[isWorkButton setHidden:NO];
		[isTrackedButton setHidden:NO];
	}
}

- (void) clickList: (id) sender
{
	protocol.listNameStr = listsCombo.stringValue;
}

-(NSArray*) getTasks;
{
	if (protocol){
		return protocol.tasksList;
	}
	return nil;
}

-(void) refreshTasks
{
	[protocol updateList:self callback:@selector(taskRefreshDone)];
}

-(NSString*) projectForTask: (NSString *) task
{
	return name;
}

- (void) newTask:(NSString *)tName completeHandler:(NSObject*) target selector: (SEL) callback
{
	NewTaskHandler *nth = [[NewTaskHandler alloc]initWithContext: protocol
														delegate:target
														selector:callback];
	nth.dictionary = [NSDictionary dictionaryWithObject:tName forKey: @"name"];
	[nth start];
}

- (void) markComplete:(NSDictionary *)ctx completeHandler: (NSObject*) target selector: (SEL) callback
{
	CompleteProcessHandler *cph = [[CompleteProcessHandler alloc]initWithContext: protocol
																		delegate:target
																		selector:callback];
	cph.dictionary = ctx;
	[cph start];
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	NSDictionary *taskInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							[ctx objectForKey:@"name"], @"task",
							[ctx objectForKey:@"project"], @"project",
							[ctx objectForKey:@"project"], @"source",
							nil];
	[dnc postNotificationName:[self completeQueue] object:nil userInfo: taskInfo];
}

//
// if there is an error then put out an error message saying results may be out of date 
// but return the last copy of the list
- (void) handleRTMError:(NSDictionary*) errInfo
{
 //   NSString *msg = [errInfo objectForKey:@"msg"];
    //NSLog(@"Error communicating with Remember The Milk [%@]", msg);
    [BaseInstance sendErrorToHandler:handler
                               error:@"Could not contact Remember the Milk at this time. Using last known task list."
                              module:name];
    [self listDone];
}

- (NSDictionary*) idMapping
{
	if (protocol){
		return protocol.idMapping;
	}
	return nil;
}

@end
