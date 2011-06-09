//
//  GCalModule.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "GCalModule.h"
#import "WPAAlert.h"
#import "Utility.h"
#import "XMLParse.h"
#import "CalDAVParser.h"

#define EMAIL @"Email"
#define PASSWORD @"Password"
#define REFRESH @"Refresh"
#define CALURL @"CalURL"
#define LOOKAHEAD @"LookAhead"
#define WARNINGWINDOW @"WarningWindow"

@implementation GCalModule
@synthesize userStr;
@synthesize passwordStr;
@synthesize respBuffer;
@synthesize userField;
@synthesize passwordField;
@synthesize refreshField;
@synthesize lookAheadField;
@synthesize lookAhead;
@synthesize stepperRefresh;
@synthesize stepperLookAhead;
@synthesize calURLField;
@synthesize calURLStr;
@synthesize refreshDate;
@synthesize addThis;
@synthesize alarmsList;
@synthesize warningWindow;
@synthesize stepperWarning;
@synthesize warningField;
@synthesize currentEvent;
@synthesize summaryMode;
@synthesize eventsList;
@synthesize alertHandler;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;

-(void) setId
{
	name =@"GCal Module";
	notificationName = @"Event Alert";
	notificationTitle = @"Upcoming Event";
	category = CATEGORY_EVENTS;
	warningWindow = 15;
	summaryTitle = @"Calendar Events";
}

-(id) init
{
	self = [super init];
	if (self){
		[self setId];
	}
	return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self setId];
	}
	return self;
}

-(void) refreshData
{
	if (alarmsList != nil && [alarmsList count] > 0){
		int count = [alarmsList count];
		while (count > 0) {
			NSTimer *timer = [alarmsList objectAtIndex:count - 1];
			[timer invalidate];
			[alarmsList removeLastObject];
			count --;
		}
	}
	refreshDate = [NSDate new];
	NSString *urlStr = [[NSString alloc]initWithString:calURLStr];
	NSURL *url = [[[NSURL alloc]initWithString:urlStr]autorelease];
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url];
	NSString *credentials = [[NSString alloc]initWithFormat:@"%@:%@",userStr,passwordStr ];
	credentials = [Utility base64EncodedString: [credentials UTF8String] withLength: [credentials length]];
	NSString *authStr = [[NSString alloc]initWithFormat:@"Basic %@", credentials ];
	////NSLog(@"auth str = [%@]", authStr);
	[theRequest addValue:authStr forHTTPHeaderField: @"Authorization"];
//	//NSLog(@"req = %@", theRequest);
//	//NSLog(@"req body = %@", theRequest.HTTPBody);
	respBuffer = [[NSMutableData alloc]init];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (!theConnection) {
		// Inform the user that the connection failed.
		[BaseInstance sendErrorToHandler:alertHandler 
								   error:[NSString stringWithFormat:@"No connection for url %@",urlStr] 
								  module:name];
	}
}

-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary useCache: (BOOL) cached
{
	alertHandler = handler;
	[self refreshData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//if ([response isKindOfClass: [NSHTTPURLResponse class]] == YES){
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
	
    // inform the user
    NSString* err = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSLocalizedRecoverySuggestionErrorKey]];
	
	if ([[error localizedDescription] rangeOfString: @"offline"].length > 0){
		// just log this error -- we are having connection problems
		//NSLog(@"%@", err);
	} else {
		[BaseInstance sendErrorToHandler:alertHandler error: err module: name];
	}

	if (validationHandler){
		SEL validSel = @selector(validationComplete:);
		[validationHandler performSelector:validSel
									  withObject:[error localizedDescription]];
	}
}


#define AUTHERR @"<HEAD>\n<TITLE>Unauthorized</TITLE>\n</HEAD>"
#define SUCCESSSTR @"BEGIN:VCALENDAR"
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *respStr = [[[NSString alloc] initWithData:respBuffer encoding:NSUTF8StringEncoding]autorelease];
	NSRange successRange = [respStr rangeOfString:SUCCESSSTR];
	if (successRange.location == NSNotFound){
		// Some failure occurred
		//NSLog(@"%@",respStr);
		NSString *errStr = @"Unknown error occurred see log for details";
		NSRange authRange = [respStr rangeOfString:AUTHERR];
		
		if (authRange.location != NSNotFound){
			errStr = @"Authentication Failure";
		}
		if (!validationHandler){
			[BaseInstance sendErrorToHandler:alertHandler 
									   error:errStr
									  module:[self name]];
			return;
		} else {
			[validationHandler performSelector:@selector(validationComplete:) 
									withObject:errStr];		
		}
	} 
	else if (validationHandler){
		[validationHandler performSelector:@selector(validationComplete:) 
								withObject:nil];
	}
	CalDAVParser *parser = [[CalDAVParser alloc]init];
	parser.data = respStr;
	eventsList = [NSMutableArray new];
	[parser parse:self];
	[self processEvents];
}

- (void) processEvents
{

	for (NSDictionary *event in eventsList){
		WPAAlert *note = [[WPAAlert alloc]init];
		note.moduleName = name;
		NSDate *eventDate = [event objectForKey:EVENT_START];
		note.title = [self timeStrFor:eventDate];
		note.message = [event objectForKey:EVENT_SUMMARY];
		note.params = event;
		
		[alertHandler handleAlert:note];
		
		if (!summaryMode){
			NSTimeInterval fireTime = [eventDate timeIntervalSinceNow];
			fireTime -= warningWindow;
			NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:fireTime 
															  target:self 
															selector:@selector(handleWarningAlarm:) 
															userInfo:note
															 repeats:NO];
			if (alarmsList == nil){
				alarmsList = [NSMutableArray new];
			}
			[alarmsList addObject: timer];
		}
	}
	[BaseInstance sendDone: alertHandler module: name];
}


-(void)beginEvent
{
	addThis = NO;
	currentEvent = [NSMutableDictionary new];
}
#define ONEDAYSECS (60 * 60 * 24)
// this will return true only if the tested date is later than now and before the end
// of the lookahead window.
// an exact match of now or the edge of the window will return false (no big deal) 
-(BOOL) isInLookAhead: (NSDate*) date
{
	NSDateFormatter *compDate = [NSDateFormatter new];
	[compDate  setDateFormat:@"MM/dd/yy hh:mm" ];
	NSDate *today = [NSDate date];
	NSDate *window = [today dateByAddingTimeInterval:ONEDAYSECS * lookAhead];
	NSComparisonResult compareToNow = [date compare:today];
	NSComparisonResult compareToLater = [date compare:window];
	return (compareToNow == NSOrderedDescending && compareToLater == NSOrderedAscending );
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

-(void) endEvent {
	if (addThis == YES){
		[currentEvent setObject: self.name forKey:REPORTER_MODULE];
		[eventsList addObject:[NSDictionary dictionaryWithDictionary:currentEvent]];
	}
}

- (void) handleWarningAlarm: (NSTimer*) theTimer
{
	WPAAlert *alert = (WPAAlert*)[theTimer userInfo];
	[alertHandler handleAlert:alert];
}

-(void)summary: (NSString*) str
{
	
	[currentEvent setObject:str forKey:EVENT_SUMMARY];
}

-(void) eventDescription: (NSString*) str
{
	[currentEvent setObject:str forKey:EVENT_DESC];
}

-(void) location: (NSString*) str
{
	[currentEvent setObject:str forKey:@"location"];
}

-(void)dateStart: (NSString*) stamp
{
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[inputFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z\r\n'"];
	NSDate *start = [inputFormatter dateFromString:stamp]; 
	if ([self isInLookAhead:start]){
		addThis = YES;
	}
	[currentEvent setObject:start forKey:EVENT_START];
}

-(void)dateEnd: (NSString*) stamp
{
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[inputFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z\r\n'"];
	NSDate *endDate = [inputFormatter dateFromString:stamp]; 

	[currentEvent setObject:endDate forKey:EVENT_END];
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	userStr = userField.stringValue;
	passwordStr = passwordField.stringValue;
	refreshInterval = refreshField.intValue * 60;
	calURLStr = calURLField.stringValue;
	warningWindow = warningField.intValue;
	lookAhead = lookAheadField.intValue;
	[self refreshData];
}

-(void) saveDefaults{
	[super saveDefaults];
	[super saveDefaultValue:userStr forKey:EMAIL];
	[super saveDefaultValue:passwordStr forKey:PASSWORD];
	[super saveDefaultValue:calURLStr forKey:CALURL];
	[super saveDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super saveDefaultValue:[NSNumber numberWithInt:warningWindow] forKey:WARNINGWINDOW];
	[super saveDefaultValue:[NSNumber numberWithInt:lookAhead] forKey:LOOKAHEAD];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) loadView
{
	[super loadView];

	[userField setStringValue:userStr == nil ? @"" : userStr];
	[passwordField setStringValue:passwordStr == nil ? @"" : passwordStr];
	[refreshField setIntValue:refreshInterval / 60];
	[calURLField setStringValue:calURLStr == nil ? @"" : calURLStr];
	[lookAheadField setIntValue:lookAhead];
	[warningField setIntValue:warningWindow];
}

-(void) loadDefaults
{
	[super loadDefaults];
	passwordStr = [super loadDefaultForKey:PASSWORD];
	userStr = [super loadDefaultForKey:EMAIL];
	calURLStr = [super loadDefaultForKey:CALURL];
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
	[super clearDefaultValue:userStr forKey:EMAIL];
	[super clearDefaultValue:passwordStr forKey:PASSWORD];
	[super clearDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[super clearDefaultValue:[NSNumber numberWithInt:lookAhead] forKey:LOOKAHEAD];
	[super clearDefaultValue:[NSNumber numberWithInt:warningWindow] forKey:WARNINGWINDOW];
	[super clearDefaultValue:calURLStr forKey:CALURL];
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
- (void) handleClick: (NSDictionary*) params
{
}
@end
