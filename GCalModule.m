//
//  GCalModule.m
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GCalModule.h"
#import "Note.h"
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
@synthesize refresh;
@synthesize summaryStr;
@synthesize userField;
@synthesize passwordField;
@synthesize refreshField;
@synthesize lookAheadField;
@synthesize lookAhead;
@synthesize refreshTimer;
@synthesize stepperRefresh;
@synthesize stepperLookAhead;
@synthesize calURLField;
@synthesize calURLStr;
@synthesize locationStr;
@synthesize refreshDate;
@synthesize eventDate;
@synthesize eventDescStr;
@synthesize addThis;
@synthesize alarmsList;
@synthesize warningWindow;
@synthesize stepperWarning;
@synthesize warningField;


-(void) setId
{
	super.description =@"GCal Module";
	super.notificationName = @"Event Alert";
	super.notificationTitle = @"Upcoming Event";
	warningWindow = 15;
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

-(void) refreshData: (NSTimer*) theTimer
{
	if (refreshTimer != nil){
		[refreshTimer invalidate];
		refreshTimer = nil;
	}
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
	//NSLog(@"auth str = [%@]", authStr);
	[theRequest addValue:authStr forHTTPHeaderField: @"Authorization"];
//	NSLog(@"req = %@", theRequest);
//	NSLog(@"req body = %@", theRequest.HTTPBody);
	respBuffer = [[NSMutableData alloc]init];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (!theConnection) {
		// Inform the user that the connection failed.
		[super sendError:[NSString stringWithFormat:@"No connection for url %@",urlStr] 
				  module:[self description]];
	}
}


-(void) start
{
	super.started = YES;
	[self refreshData:nil];
}
-(void) putter
{
	[self refreshData:nil];
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
	[super sendError: err module: [self description]];
	if (super.validationHandler){
		SEL validSel = @selector(validationComplete:);
		[super.validationHandler performSelector:validSel
									  withObject:[error localizedDescription]];
	}
	[refreshTimer invalidate];
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
			[super sendError:@"Authentication Failure" module:[self description]];
			return;
		} else {
			[super.validationHandler performSelector:@selector(validationComplete:) 
										  withObject:@"Authentication Failure"];		
		}
	} 
	else if (super.validationHandler){
		[super.validationHandler performSelector:@selector(validationComplete:) 
									  withObject:nil];
	}
	CalDAVParser *parser = [[CalDAVParser alloc]init];
	parser.data = respStr;
	[parser parse:self];
}
-(void) goAway
{
}

-(void) think
{
}
- (void) doesNotRecognizeSelector:(SEL)aSelector
{
	[super doesNotRecognizeSelector:aSelector];
}
-(void)beginEvent
{
	addThis = NO;
}
#define ONEDAYSECS (60 * 60 * 24)
// this will return true only if the tested date is later than now and before the end
// of the lookahead window.
// an exact match of now or the edge of the window will return false (no big deal) 
-(BOOL) isInLookAhead: (NSDate*) date
{
	NSDate *today = [NSDate date];
	NSDate *window = [today dateByAddingTimeInterval:ONEDAYSECS * lookAhead];
	NSComparisonResult compareToNow = [date compare:today];
	NSComparisonResult compareToLater = [date compare:window];
	if (compareToNow == NSOrderedDescending){
	}
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
		[timeDate setDateFormat: @"ddd' at 'hh:mm"];
		ret = [timeDate stringFromDate:date];
	}
	return ret;
}

-(void)endEvent{
	if (addThis == YES){
		
		Note *note = [[Note alloc]init];
		note.moduleName = super.description;
		note.title = [self timeStrFor:eventDate];
		note.message = summaryStr;

		[[super handler] handleAlert:note];
		
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

- (void) handleWarningAlarm: (NSTimer*) theTimer
{
	Note *alert = (Note*)[theTimer userInfo];
	[[super handler] handleAlert:alert];
}

-(void)summary: (NSString*) str
{
	self.summaryStr = str;
}

-(void) eventDescription: (NSString*) str
{
	self.eventDescStr = str;
}

-(void) location: (NSString*) str
{
	self.locationStr = str;
}

-(void)dateStart: (NSString*) stamp
{
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[inputFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z\r\n'"];
	eventDate = [inputFormatter dateFromString:stamp]; 
	if ([self isInLookAhead:eventDate]){
		addThis = YES;
	}
//	NSComparisonResult res = [eventDate compare:refreshDate];
//	NSDateFormatter *outDate = [NSDateFormatter new];;
//	[outDate  setDateFormat:@"MM'/'dd'/'yy @ HH:mm" ];
//	NSLog(@"event date:%@", [outDate stringFromDate:eventDate]);
//	if (res ==  NSOrderedDescending){
//		NSLog(@"adding this");
//		addThis = YES;
//	}
}

-(void)dateEnd: (NSString*) stamp
{
}

- (void) scheduleNextRefresh
{
	SEL refData = @selector(refreshData:);
	NSMethodSignature *sig = [self methodSignatureForSelector:refData];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setTarget:self];
	//refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refresh invocation:inv repeats:NO];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refresh * 60
													  target:self 
													selector:@selector(refreshData:)
													userInfo:nil
													 repeats:NO];
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	userStr = userField.stringValue;
	passwordStr = passwordField.stringValue;
	refresh = refreshField.intValue;
	calURLStr = calURLField.stringValue;
	warningWindow = warningField.intValue;
	lookAhead = lookAheadField.intValue;
	[self refreshData: nil];
}

-(void) saveDefaults{
	[super saveDefaults];
	[super saveDefaultValue:userStr forKey:EMAIL];
	[super saveDefaultValue:passwordStr forKey:PASSWORD];
	[super saveDefaultValue:calURLStr forKey:CALURL];
	[super saveDefaultValue:[NSNumber numberWithInt:refresh] forKey:REFRESH];
	[super saveDefaultValue:[NSNumber numberWithInt:warningWindow] forKey:WARNINGWINDOW];
	[super saveDefaultValue:[NSNumber numberWithInt:lookAhead] forKey:LOOKAHEAD];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) loadView
{
	[super loadView];

	[userField setStringValue:userStr == nil ? @"" : userStr];
	[passwordField setStringValue:passwordStr == nil ? @"" : passwordStr];
	[refreshField setIntValue:refresh];
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
		refresh = [temp intValue];
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
	[super clearDefaultValue:[NSNumber numberWithInt:refresh] forKey:REFRESH];
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
@end
