//
//  GoogleTodoModule.m
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
#import "GoogleTodoModule.h"
#import "WPAAlert.h"
#import "RequestREST.h"
#import "ListHandler.h"
#import "ListsHandler.h"
#import "TokenHandler.h"
#import "RefreshHandler.h"
#import "RefreshListHandler.h"
#import "Utility.h"
#import "CompleteProcessHandler.h"
#import "NewTaskHandler.h"
#import "GoogleTaskEditCtrl.h"
#import "SiSData.h"

@implementation GoogleTodoModule 

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
@synthesize lookAheadWindow;
@synthesize lookAheadText;
@synthesize protocol;
@synthesize isTrackedButton;
@synthesize projectPopup;
@synthesize projectLabel;

@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;
@dynamic summaryTitle;
@dynamic isWorkRelated;
@dynamic summaryMode;
@dynamic baseQueue;
@dynamic defaultProject;


/**
 Responding to refresh tracking items
 */
- (void) taskRefreshDone
{
//	[super saveDefaultValue:protocol.tasksList forKey:TASKLIST];
	NSNotification *notice = [NSNotification notificationWithName:@"com.zer0gravitas.tasks" object:self];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotification:notice];
}

- (void) listDone 
{
	[super saveDefaultValue:protocol.tasksList forKey:TASKLIST];
	for (NSDictionary *taskData in protocol.tasksList){
		WPAAlert *alert = [[WPAAlert alloc]init];
		alert.message=[taskData objectForKey: @"name"];
		alert.moduleName = name;
		alert.title =name;
		alert.params = taskData;
		alert.lastAlert = NO;
		[handler handleAlert:alert];
	}
	if (summaryMode) {
		[BaseInstance sendDone:handler module: name];	
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
	if (cached) {
		[self listDone];
		return;
	}
	self.handler = alertHandler;
	summaryMode = summary;
	[protocol updateList:self returnTo:@selector(refreshDone)];
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
	NSDictionary *taskParams = [NSDictionary dictionaryWithDictionary:(NSDictionary*) ctx];
//	NSString *clickName = [taskParams objectForKey:@"name"];
	GoogleTaskEditCtrl *dialogCtrl= [[GoogleTaskEditCtrl alloc] 
									   initWithWindowNibName:@"GoogleTaskEdit" 
											   usingProtocol: protocol
													forTask: taskParams
													usingQueue: [self completeQueue]];
	[dialogCtrl showWindow:self];
	
	//NSLog(@"name: %@",clickName, nil);
}

- (void) gtProtocol: (GTProtocol*) proto callEndingAt: (SelWrapper*) selWrap gotError:  (NSError*) error  
{
	if (selWrap.selector == @selector(refreshTasks)){
		NSLog(@"error in refresh");
	}
	else{
		NSLog(@"how did I get here?");
	}
}

- (void) initGuts
{

	name =@"Google Todo Module";
	notificationName = @"Task Alert";
	notificationTitle = @"Task Msg";
	category = CATEGORY_TASKS;
	summaryTitle = @"Current Tasks";
	refreshInterval = 15 * 60;
	lookAheadWindow = 60 * 60 * 24 * 7.0;
	[refreshText setIntValue:refreshInterval / 60];	
	protocol = [GTProtocol new];
	[protocol setErrorCallback:@selector(handleError:returnSelector:)];
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

- (void) refreshView
{
	[self loadView];
}

- (void) setupProjects
{
	NSArray *projects = [SiSData getAllActiveProjects];
	for (NSString *projName in projects){
		[projectPopup addItemWithTitle:projName];
	}
	[projectPopup selectItemWithTitle:defaultProject];
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
	[lookAheadText setIntValue: (lookAheadWindow / 24 / 60 / 60)];
	[lookAheadText setHidden:YES];
	[isWorkButton setHidden:YES];
	[isWorkButton setIntValue:isWorkRelated];
	[isTrackedButton setHidden:YES];
	[isTrackedButton setIntValue:tracked];
	[refreshText setIntValue: refreshInterval / 60];
	if (protocol.auth) {
		[authButton setHidden:YES];
		[progInd startAnimation:self];
		[progInd setHidden:NO];
		[protocol getLists:self returnTo:@selector(listsDone)];
	}
	[self setupProjects];
	[projectPopup setHidden:YES];
	[projectLabel setHidden:YES];
}

-(void) loadDefaults
{
	[super loadDefaults];
	protocol.listNameStr = [super loadDefaultForKey:LISTNAME];
	protocol.listIdStr = [super loadDefaultForKey:LISTID];
	[protocol loadAuth:[super loadDefaultForKey:TOKEN]];
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
	[super clearDefaults];
	[super clearDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super clearDefaultValue:protocol.listNameStr forKey:LISTNAME];
	[super clearDefaultValue: protocol.listIdStr forKey:LISTID];
	[super clearDefaultValue: nil forKey:TOKEN];
	[super clearDefaultValue: [NSNumber numberWithDouble:lookAheadWindow] forKey:LOOKAHEAD];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) saveDefaults
{
	[super saveDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super saveDefaultValue:protocol.listNameStr forKey:LISTNAME];
	[super saveDefaultValue: protocol.listIdStr forKey:LISTID];
    [super saveDefaultValue:[NSNumber numberWithDouble:lookAheadWindow] forKey:LOOKAHEAD];
	[super saveDefaultValue:[protocol authStr] forKey:TOKEN];
	[[NSUserDefaults standardUserDefaults] synchronize];		
	[super saveDefaults];
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];

	refreshInterval = (refreshText.intValue * 60);
	lookAheadWindow = (lookAheadText.intValue * 60 * 60 * 24);
	isWorkRelated = [isWorkButton intValue];
	tracked = [isTrackedButton intValue];
	protocol.listNameStr = [listsCombo titleOfSelectedItem];
	NSDictionary *listInfo =  [[self idMapping] objectForKey:protocol.listNameStr];
	protocol.listIdStr = [listInfo objectForKey:@"id"];
	defaultProject = [projectPopup titleOfSelectedItem];
	[validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];	
}

- (void) authDone
{
	if ([protocol auth] != nil) {
		[protocol getLists:self returnTo:@selector(listsDone)];
	}
}

- (void) clickAuthButton: (id) sender
{

	// step 1 - get a Frob string in preparation for application authorization
	NSWindow *win = [[self view] window];
	[protocol getTokenInWindow:win handler:self returnTo:@selector(authDone)];
	[progInd setHidden:NO];
	[progInd startAnimation:self];

}

- (void) listsDone 
{
	[progInd stopAnimation:self];
	[progInd setHidden: YES];	
	if (protocol.idMapping == nil){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Error getting task lists" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Hmmm I could not get a token to authorizing this application.  Lets try authorizing again."];
		authButton.title =@"Authorize";
		[alert runModal];
		[authButton setHidden:NO];
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
		[authButton setHidden:YES];
		[projectPopup setHidden:NO];
		[projectLabel setHidden:NO];
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
	[protocol updateList:self returnTo:@selector(taskRefreshDone)];
}

-(NSString*) projectForTask: (NSString *) task
{
	return name;
}

- (void) newTask:(NSString *)tName completeHandler:(NSObject*) target selector: (SEL) callback
{
	[protocol sendAdd:target returnTo:callback params:[NSDictionary dictionaryWithObject: tName forKey:@"title"]];
}

- (void) completeDone
{
}

- (void) markComplete:(NSDictionary *)ctx completeHandler: (NSObject*) target selector: (SEL) callback
{
	[protocol sendComplete:target returnTo:callback params:ctx];
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
