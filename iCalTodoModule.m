//
//  GCalModule.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "iCalTodoModule.h"
#import "WPAAlert.h"
#import "Utility.h"
#import "iCal.h"

#define MAILBOX @"MailBox"
#define REFRESH @"Refresh"
#define CALENDAR @"Calendar"
#define LOOKAHEAD @"LookAhead"
#define WARNINGWINDOW @"WarningWindow"

@implementation iCalTodoModule
@synthesize respBuffer;
@synthesize calendarMenu;
@synthesize refreshField;
@synthesize lookAheadField;
@synthesize lookAhead;
@synthesize stepperRefresh;
@synthesize stepperLookAhead;
@synthesize calendarName;
@synthesize refreshDate;
@synthesize addThis;
@synthesize alarmsList;
@synthesize warningWindow;
@synthesize stepperWarning;
@synthesize warningField;
@synthesize currentEvent;
@synthesize summaryMode;
@synthesize tasksList;
@synthesize alertHandler;
@synthesize iCalDateFmt;
@synthesize msgName;
@synthesize scriptCallback;
@synthesize completeHandler;
@synthesize completeCaller;
@synthesize isWorkButton;
@synthesize isTrackedButton;

@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;
@dynamic summaryTitle;
@dynamic isWorkRelated;

-(void) setId
{
	name =@"iCal Todo Module";
	notificationName = @"Task Alert";
	notificationTitle = @"Upcoming Task";
	category = CATEGORY_TASKS;
	warningWindow = 15;
	summaryTitle = @"Tasks";
	lookAhead = 7;
	refreshInterval = 60 * 60.0;
}

-(id) init
{
	self = [super init];
	if (self){
		[self setId];
	}
	return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil params:(NSDictionary*) appParams
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil params:appParams];
	if (self)
	{
		[self setId];
	}
	return self;
}

#define ONEDAYSECS (60 * 60 * 24)	

//
// the message name is used to name a private notification back from the scripting monitor
// so just use a timestamp to keep the name unique
//
- (NSString*) msgName
{
    if (!msgName){
        NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
        msgName = [@"com.zer0gravitas.iCalDone" stringByAppendingString:[[NSNumber numberWithDouble:ti] stringValue]];
    }
    return msgName;
}

- (void) fetchDone
{
	NSLog(@"fetchDone");
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:[self msgName] object:nil];
	NSLog(@"tasksList count = %d", [tasksList count]);
	NSDate *nowDate = [NSDate date];
	if (alertHandler == nil) {
		NSNotification *notice = [NSNotification notificationWithName:@"com.zer0gravitas.tasks" object:self];
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotification:notice];
		return;
	}
	for (NSMutableDictionary *item in tasksList){
		WPAAlert *alert = [[WPAAlert alloc]init];
		NSString *alertTitle = [calendarName copy];
		alert.title = alertTitle;
		alert.clickable = YES;
		
		alert.message=[item objectForKey:@"name"];
		alert.params = item;
		
		NSDate *dueDate = [item objectForKey:@"due_time"];
		NSComparisonResult dueCheck = NSOrderedSame; // this will *stay* if there is no date
		if (dueDate){
			dueCheck = [dueDate compare:nowDate];
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
		[alertHandler handleAlert:alert];
		
		if (dueCheck == NSOrderedDescending) {
			NSTimeInterval dueInterval = [dueDate timeIntervalSinceNow];
			if (alarmsList == nil){
				alarmsList = [NSMutableDictionary new];
			}
			WPAAlert *alarm = [alert copy];
			alarm.title =[calendarName stringByAppendingString:@" [Task Due Now]"];
			alarm.urgent = YES;
			alarm.sticky = YES;
			NSString *key = [NSString stringWithFormat:@"%@%@",
							 [dueDate description],
							 [item objectForKey:@"name"]];
			// if we do not already have an alarm set -- set it
			if ([alarmsList objectForKey:key] == nil){
				NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:dueInterval
																  target:self 
																selector:@selector(handleWarningAlarm:)
																userInfo:alarm
																 repeats:NO]; 
				
				[alarmsList setObject:timer forKey:key];	
			}
		}	
    }
	[BaseInstance sendDone: alertHandler module: name];
}

- (void) sendFetchWithScript: (NSString*) script
{
	NSDictionary *params = nil;
	if (script) {
		NSLog(@"sending fetch with script");
		params = [NSDictionary dictionaryWithObjectsAndKeys:script, @"script",
				  [self msgName], @"callback", 
                  @"task", @"handler",
				  nil];
	} else {
		NSLog(@"sending fetch without script");
		params = [NSDictionary dictionaryWithObjectsAndKeys: [self msgName], @"callback", nil];
	}
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc postNotificationName:@"com.zer0gravitas.icaldaemon" object:nil userInfo:params];
}

-(void) fetchTasks
{
//	if([self launchDaemonIfNeeded]) {
//		return;
//	}
    NSDate *today = [NSDate date];
    NSDate *window = [today dateByAddingTimeInterval:ONEDAYSECS * lookAhead]; 
    if (iCalDateFmt == nil){
        iCalDateFmt = [NSDateFormatter new];
        [iCalDateFmt setDateFormat:@"EEEE, MMMM dd, yyyy hh:mm:ss a"];
    }
//    NSString *nowStr = [iCalDateFmt stringFromDate:today];
    NSString *thenStr = [iCalDateFmt stringFromDate:window];
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle resourcePath];
    path = [path stringByAppendingFormat:@"/%@",@"todoFetchTemplate.txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    script = [script stringByReplacingOccurrencesOfString:@"<calName>" withString:calendarName];
	script = [script stringByReplacingOccurrencesOfString:@"<eDate>" withString:thenStr];
    NSLog(@"script = %@",script);
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc addObserver:self 
			selector:@selector(taskFetched:)
				name:[self msgName]
			  object:nil
	 ];
	[self sendFetchWithScript:script];
}

-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary useCache: (BOOL) cached
{
	alertHandler = handler;
    summaryMode = summary;
    if (!tasksList) {
        tasksList = [NSMutableArray new];
    }
    [tasksList removeAllObjects];
    //NSLog(@"msg = %@",[self msgName]);
    
	[self fetchTasks];
}

- (void) refreshTasks{
	[self refresh: nil isSummary: NO useCache:NO];
}

- (void) taskFetched: (NSNotification*) notification
{
	NSDictionary *msg = [notification userInfo];
	NSString *errStr = [msg objectForKey:@"error"];
	if (errStr){		
		NSLog(@"got error %@", errStr);
		NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
		[dnc removeObserver:self name:[self msgName] object:nil];
		//	[self performSelector:fetchCallback];
		[self fetchDone];
	}
	else {
		if ([msg count] == 0){
			NSLog(@"end of file");
			NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
			[dnc removeObserver:self name:[self msgName] object:nil];
			[self fetchDone];
		} else {
			NSLog(@"got message");
			[tasksList addObject:[NSMutableDictionary dictionaryWithDictionary:msg]];
			[self sendFetchWithScript:NO];
		}
	}
}

-(void) openTodo: (NSObject*) param
{
	NSDictionary *dict = (NSDictionary*) param;
	NSString *msgId = [dict objectForKey:@"id"];
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle resourcePath];
    path = [path stringByAppendingFormat:@"/%@",@"openTodo.txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    script = [script stringByReplacingOccurrencesOfString:@"<calName>" withString:calendarName];
    script = [script stringByReplacingOccurrencesOfString:@"<idParam>" withString:msgId];
	[self sendFetchWithScript:script];
}

-(void) handleClick: (NSDictionary*) ctx
{
    [[NSWorkspace sharedWorkspace] launchApplication:@"iCal"];
 //   //NSLog(@"launched = %d", res);	
	[self openTodo:ctx];
}

-(NSString*) timeStrFor:(NSDate*) date
{
	NSString *ret = nil;
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"yyyyMMdd" ];
	NSString *todayStr = [compDate stringFromDate:[NSDate date]];
	NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:24*60*60];
	NSString *tomorrowStr = [compDate stringFromDate:tomorrow];
	NSString *eDateStr = [compDate stringFromDate:date];
	if ([todayStr isEqualToString:eDateStr]){
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"hh:mm"];
		ret = [NSString stringWithFormat:@"Today at %@", [timeDate stringFromDate:date]];
	}
	else if ([tomorrowStr isEqualToString:eDateStr] ){
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"hh:mm"];
		ret = [NSString stringWithFormat:@"Tomorrow at %@", [timeDate stringFromDate:date]];
		
	}else{
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"MM/dd' at 'hh:mm"];
		ret = [timeDate stringFromDate:date];
	}
	return ret;
}


- (void) handleWarningAlarm: (NSTimer*) theTimer
{
	WPAAlert *alert = (WPAAlert*)[theTimer userInfo];
	[alertHandler handleAlert:alert];
}


- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	calendarName = [calendarMenu titleOfSelectedItem];
	refreshInterval = refreshField.intValue * 60;
	warningWindow = warningField.intValue;
	lookAhead = lookAheadField.intValue;
	tracked = [isTrackedButton intValue];
	isWorkRelated = [isWorkButton intValue];

    [validationHandler performSelector:@selector(validationComplete:) 
                            withObject:nil];}

-(void) saveDefaults{
	[super saveDefaults];
	[super saveDefaultValue:calendarName forKey:CALENDAR];
	[super saveDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super saveDefaultValue:[NSNumber numberWithInt:warningWindow] forKey:WARNINGWINDOW];
	[super saveDefaultValue:[NSNumber numberWithInt:lookAhead] forKey:LOOKAHEAD];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadMenu
{
    iCalApplication *calApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.ical"];
	if (calApp) {
		for ( iCalCalendar *cal in calApp.calendars){
            [calendarMenu addItemWithTitle:cal.name];
        }
    }
    if ([[calendarMenu itemArray] count] == 0){
        [calendarMenu addItemWithTitle:@"No Calendars"];
        [calendarMenu setEnabled:NO];
    }
}

-(void) loadView
{
	[super loadView];
    [self loadMenu];
	[calendarMenu setStringValue:calendarName == nil ? @"" : calendarName];
	[refreshField setIntValue:refreshInterval / 60];
	[lookAheadField setIntValue:lookAhead];
	[warningField setIntValue:warningWindow];
	[isWorkButton setIntValue:isWorkRelated];
	[isTrackedButton setIntValue:tracked];
}

-(void) loadDefaults
{
	[super loadDefaults];
	calendarName = [super loadDefaultForKey:CALENDAR];
	NSNumber *temp =  [super loadDefaultForKey:REFRESH];
	if (temp) {
		refreshInterval = [temp intValue];
	}
	temp =  [super loadDefaultForKey:LOOKAHEAD];
	if (temp) {
		lookAhead = [temp intValue];
	}
	temp =  [super loadDefaultForKey:WARNINGWINDOW];
	if (temp) {
		warningWindow = [temp intValue];
	}
}

-(void) clearDefaults{
	[super clearDefaults];
	[super clearDefaultValue:calendarName forKey:CALENDAR];
	[super clearDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super clearDefaultValue:[NSNumber numberWithInt:lookAhead] forKey:LOOKAHEAD];
	[super clearDefaultValue:[NSNumber numberWithInt:warningWindow] forKey:WARNINGWINDOW];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(IBAction) clickRefreshStepper: (id) sender
{
	refreshField.intValue = stepperRefresh.intValue;
}

-(IBAction) clickLookAheadStepper: (id) sender
{
	lookAheadField.intValue = stepperLookAhead.intValue;
}

-(IBAction) clickWarningStepper: (id) sender
{
	warningField.intValue = stepperWarning.intValue;
}

- (void) changeState: (WPAStateType) state
{
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc postNotificationName: @"com.zer0gravitas.icaldaemon.quit" object:@"iCalTodoModule"];
}
- (NSString*) projectForTask: (NSString*) task{
	return calendarName;
}

- (void) didComplete: (NSNotification *) msg
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:[self msgName] object:nil];
	[completeCaller performSelector: completeHandler];
}

- (void) markComplete:(NSDictionary *)ctx completeHandler:(NSObject*) target selector: (SEL) handler
{
	NSString *msgId = [ctx objectForKey:@"id"];
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle resourcePath];
    path = [path stringByAppendingFormat:@"/%@",@"completeTodo.txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    script = [script stringByReplacingOccurrencesOfString:@"<calName>" withString:calendarName];
    script = [script stringByReplacingOccurrencesOfString:@"<idParam>" withString:msgId];
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc addObserver:self 
			selector:@selector(didComplete:)
				name:[self msgName]
			  object:nil
	 ];
	completeCaller = target;
	completeHandler = handler;
	[self sendFetchWithScript:script];
}

- (void) didCreate: (NSNotification *) msg
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:[self msgName] object:nil];
	[completeCaller performSelector: completeHandler];
}

- (void) newTask:(NSString *)summary  completeHandler:(NSObject*) target selector: (SEL) handler {
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle resourcePath];
    path = [path stringByAppendingFormat:@"/%@",@"createTodo.txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    script = [script stringByReplacingOccurrencesOfString:@"<calName>" withString:calendarName];
    script = [script stringByReplacingOccurrencesOfString:@"<summText>" withString:summary];
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc addObserver:self 
			selector:@selector(didCreate:)
				name:[self msgName]
			  object:nil
	 ];
	completeCaller = target;
	completeHandler = handler;	
	[self sendFetchWithScript:script];
}

- (NSArray*) getTasks
{
	return tasksList;
}
@end
