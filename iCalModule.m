//
//  GCalModule.m
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "iCalModule.h"
#import "Note.h"
#import "Utility.h"
#import "iCal.h"

#define MAILBOX @"MailBox"
#define REFRESH @"Refresh"
#define CALENDAR @"Calendar"
#define LOOKAHEAD @"LookAhead"
#define WARNINGWINDOW @"WarningWindow"

@implementation iCalModule
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
@synthesize eventsList;
@synthesize alertHandler;
@synthesize iCalDateFmt;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;

-(void) setId
{
	name =@"iCal Module";
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

- (void) handleEventDescriptor:(NSAppleEventDescriptor*) descN
{
    NSLog(@"descN count = %ld", [descN numberOfItems]);
    NSMutableDictionary *eDict = [NSMutableDictionary dictionaryWithCapacity:4];

    for(unsigned int j = 1; j <= [descN numberOfItems]; j+=2){
        NSLog(@"descN[%d]", j);
        NSAppleEventDescriptor *fieldNameDesc = [descN descriptorAtIndex:j];
        NSAppleEventDescriptor *fieldValDesc = [descN descriptorAtIndex:j+1];
        
        // typeType (aka '    ') means the result is an empty string (which means nil in this case)
        if ([fieldValDesc descriptorType] != typeType) {
            
            NSString *fieldName = [fieldNameDesc stringValue];
            if ([fieldName isEqualToString:@"sDate"]){
                NSString *dateTemp = [fieldValDesc stringValue];
                NSDate *date = [iCalDateFmt dateFromString:dateTemp];
                [eDict setValue:date forKey:EVENT_START];
            }       
            if ([fieldName isEqualToString:@"desc"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:EVENT_DESC];
            } 
            if ([fieldName isEqualToString:@"summ"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:EVENT_SUMMARY];
            } 
            if ([fieldName isEqualToString:@"unique"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:EVENT_ID];
            } 
        }
    }
    [eventsList addObject:eDict];                 
}


#define NILSCRIPT '    '
- (void) handleDescriptor: (NSAppleEventDescriptor*) aDescriptor
{
    
    UInt32 val;
    char *c = nil;
    NSLog (@"count = %ld", [aDescriptor numberOfItems]);
    DescType type = [aDescriptor descriptorType];
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
            [self handleEventDescriptor:fdesc0];
// 
//            switch (fldDesc) {
//                case typeUnicodeText:
//                    NSLog(@"text = %@", [fdesc0 stringValue]);
//                    break;
//                case typeType:
//                    val =[fdesc0 int32Value];
//                    if (val == NILSCRIPT){
//                        NSLog(@"type = nil");
//                    }
//                    c = (char*)&val;
//                    NSLog(@"type = %c%c%c%c",c[3],c[2],c[1],c[0]);
//                    break;
//                case typeAEList:
//                    val = fldDesc;
//                    c = (char*)&val;
//                    NSLog(@"list length %ld",[fdesc0 numberOfItems]);
//                    [self handleEventDescriptor:fdesc0];
//                    break;
//                default:
//                    val = fldDesc;
//                    c = (char*)&val;
//                    NSLog(@"unrecognized = %c%c%c%c",c[3],c[2],c[1],c[0]);
//            }
        }
    }
    
}
#define ONEDAYSECS (60 * 60 * 24)	

-(void) getEvents: (NSObject*) param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (!iCalDateFmt){
        iCalDateFmt = [NSDateFormatter new];
        [iCalDateFmt  setDateFormat:@"EEEE, MMMM d, yyyy hh:mm:ss a" ];
        // should look like 'Tuesday, April 12, 2011 10:00:00 AM'
    }
	NSDate *today = [NSDate date];
	NSDate *window = [today dateByAddingTimeInterval:ONEDAYSECS * lookAhead];   
    NSString *nowStr = [iCalDateFmt stringFromDate:today];
    NSString *thenStr = [iCalDateFmt stringFromDate:window];
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle resourcePath];
    path = [path stringByAppendingFormat:@"/%@",@"allEvents.txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    script = [script stringByReplacingOccurrencesOfString:@"<calName>" withString:calendarName];
    script = [script stringByReplacingOccurrencesOfString:@"<sDate>" withString:nowStr];
    script = [script stringByReplacingOccurrencesOfString:@"<eDate>" withString:thenStr];
    NSDictionary *anError = nil;
    NSAppleScript *aScript = [[NSAppleScript alloc] initWithSource:script];
    NSAppleEventDescriptor *aDescriptor = [aScript executeAndReturnError:&anError];
    NSLog(@"%@",aDescriptor);
    if (anError){
        NSLog(@"got error %@", anError);
    }
    [self handleDescriptor:aDescriptor];
    
    
     
	NSNotification *msg = [NSNotification notificationWithName:@"com.workplayaway.calFetchDone" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:msg];
	[pool drain];	
}

-(void) refreshData
{
	if (alarmsList != nil && [alarmsList count] > 0){
		UInt count = [alarmsList count];
		while (count > 0) {
			NSTimer *timer = [alarmsList objectAtIndex:count - 1];
			[timer invalidate];
			[alarmsList removeLastObject];
			count --;
		}
	}
	refreshDate = [NSDate new];
}

-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary
{
	alertHandler = handler;
    summaryMode = summary;
    if (!eventsList) {
        eventsList = [NSMutableArray new];
    }
    [eventsList removeAllObjects];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(fetchDone:)
												 name:@"com.workplayaway.calFetchDone" 
											   object:nil];
	[NSThread detachNewThreadSelector: @selector(getEvents:)
							 toTarget:self
						   withObject:nil];
}

- (void) fetchDone: (NSNotification*) note
{
	for (NSDictionary *event in eventsList){
		Note *note = [[Note alloc]init];
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
	[BaseInstance sendDone:alertHandler module: name];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.workplayaway.calFetchDone" object:nil];
}

-(void) openEvent: (NSObject*) param
{
	NSDictionary *dict = (NSDictionary*) param;
	NSString *msgId = [dict objectForKey:@"id"];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle resourcePath];
    path = [path stringByAppendingFormat:@"/%@",@"openEvent.txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    script = [script stringByReplacingOccurrencesOfString:@"<calName>" withString:calendarName];
    script = [script stringByReplacingOccurrencesOfString:@"<idParam>" withString:msgId];
    NSDictionary *anError;
    NSAppleScript *aScript = [[NSAppleScript alloc] initWithSource:script];
    [aScript executeAndReturnError:&anError];

	[pool drain];	
}

-(void) handleClick: (NSDictionary*) ctx
{
	NSDictionary *event = [NSDictionary dictionaryWithDictionary:(NSDictionary*) ctx];
    [[NSWorkspace sharedWorkspace] launchApplication:@"iCal"];
 //   NSLog(@"launched = %d", res);	
    [NSThread detachNewThreadSelector: @selector(openEvent:)
							 toTarget:self
						   withObject:event];
    
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
	Note *alert = (Note*)[theTimer userInfo];
	[alertHandler handleAlert:alert];
}


- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	calendarName = [calendarMenu titleOfSelectedItem];
	refreshInterval = refreshField.intValue * 60;
	warningWindow = warningField.intValue;
	lookAhead = lookAheadField.intValue;
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

@end
