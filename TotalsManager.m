//
//  GoalManager.m
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "TotalsManager.h"
#import "Context.h"
#import "WPADelegate.h"
#import "WriteHandler.h"
//
// Keeps track of (approximate) weekly and daily totals of away, work and free time
// the values are incremented using addInterval ( called frequently )
// the values are reset nightly and weekly and this class manages the necessary timers
//
@implementation TotalsManager
@synthesize dailyRolloverTimer, rolloverDay, rolloverHour, timeStampDate;
@synthesize awayToday, workToday, freeToday;
@synthesize awayWeek, workWeek, freeWeek;
@synthesize interval, recordChecked;

- (void) initFromRecord
{
	WPADelegate *del = (WPADelegate*)[NSApplication sharedApplication].delegate;
	NSTimeInterval rollAdjust = - (60 * 60 * rolloverHour);
	NSDate *effectiveDate = [[dailyRolloverTimer fireDate] dateByAddingTimeInterval:rollAdjust];
	NSTimeInterval work;
	NSTimeInterval free;
	[del findSummaryForDate:effectiveDate work:&work free:&free];
	if (free > 0){
		freeToday += free;
	}
	if (work > 0) {
		workToday += work;
	}
}

- (void)saveCurrent
{
	[WriteHandler sendSummaryForDate:timeStampDate 
							 goal:[[NSUserDefaults standardUserDefaults]doubleForKey:@"dailyGoal"] 
							 work:workToday 
							 free:freeToday];
}

- (void) dailyRollover: (NSTimer*) timer
{
	NSDateFormatter *compDate = [NSDateFormatter new];
	[compDate  setDateFormat:@"yyyyMMdd hh:mm" ];
	NSString *todayStr = [compDate stringFromDate:timer.fireDate];
	NSLog(@"rolling over @ %@", todayStr);
	NSTimeInterval next = 24 * 60 * 60;
	// if we are called the first time then set up the loop for every 24 hours
	if (timer.userInfo == nil){
		dailyRolloverTimer = [NSTimer scheduledTimerWithTimeInterval:next
															  target:self
															selector: @selector(dailyRollover:) 
															userInfo:[[NSDate alloc]initWithTimeIntervalSinceNow:0]
															 repeats:YES];
	}
	// write a record
	[self saveCurrent];
	timeStampDate = [timeStampDate dateByAddingTimeInterval:24 * 60 * 60];
	
	// Get the weekday component of the current date
	// and if its the rollover day.... then rollover for the week
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	awayToday = workToday = freeToday = 0;

	NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:timer.fireDate];	
	if (comps.weekday == rolloverDay){
		awayWeek = workWeek = freeWeek = 0;
	}
}

- (void) dumpRollDate: (NSDate*) rollDate andInterval: (NSTimeInterval) rollInterval
{
	NSDateFormatter *compDate = [NSDateFormatter new];
	[compDate  setDateFormat:@"yyyy-MM-dd hh:mm" ];
	NSString *rollStr = [compDate stringFromDate:rollDate];
	int hour = rollInterval / 3600; 
	int min = (((int)rollInterval) % 3600) / 60;
	NSLog(@"First Rollover is at %@, %f seconds (%d:%d) from now", rollStr, rollInterval, hour, min);
}

- (NSTimer*) getTimerForRollHour: (int) rollHour
{
	NSDate *today = [[NSDate alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	int ALLCOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
	// Get the weekday component of the current date
	NSDateComponents *rollComps = [gregorian components:ALLCOMPS fromDate:today];
	if (rollHour <= rollComps.hour){
		rollComps.day += 1;
	}
	rollComps.hour = rollHour;

	NSDate *rollDate = [gregorian dateFromComponents:rollComps];
	NSTimeInterval rollInterval = [rollDate timeIntervalSinceNow];
	
	[self dumpRollDate: rollDate andInterval: rollInterval];

	return [NSTimer scheduledTimerWithTimeInterval:rollInterval
											target:self
										  selector: @selector(dailyRollover:) 
										  userInfo:nil
										   repeats:NO];
}
- (NSDate*) getTimeStampDate: (int) rollHour
{
	NSDate *today = [[NSDate alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	int ALLCOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	// Get the weekday component of the current date
	NSDateComponents *rollComps = [gregorian components:ALLCOMPS fromDate:today];
	if (rollHour > rollComps.hour){
		rollComps.day -= 1;
	}
	rollComps.hour = rollHour;
	
	NSDate *stamp = [gregorian dateFromComponents:rollComps];
	return stamp;
}

- (id) init
{
	if (self)
	{
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		rolloverHour = ((NSNumber*)[ud objectForKey:@"dailyRolloverHour"]).intValue; // defaults to zero (aka midnight)
		NSLog(@"rollover hour: %d", rolloverHour);
		rolloverDay =  ((NSNumber*)[ud objectForKey:@"weeklyRolloverDay"]).intValue;
		interval = ((NSNumber*)[ud objectForKey:@"statusInterval"]).doubleValue; 
		timeStampDate = [[self getTimeStampDate: rolloverHour] copy];
		dailyRolloverTimer = [self getTimerForRollHour: rolloverHour];
	}
	return self;
}


- (void) addInterval:(WPAStateType) state
{
	if (!recordChecked){
		[self initFromRecord];
		recordChecked = YES;
	}
	switch (state) {
		case WPASTATE_AWAY:
			awayToday += interval;
			awayWeek += interval;
			break;
			
		case WPASTATE_FREE:
			freeToday += interval;
			freeWeek += interval;
			break;
			
		case WPASTATE_THINKING:
			workToday += interval;
			workWeek += interval;
			break;
			
		default:
			break;
	}
	[self saveCurrent];
}
+ (void) initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:0],	@"dailyRolloverHour", //midnight
								 [NSNumber numberWithInt:1],	@"weeklyRolloverDay", //sunday
								 [NSNumber numberWithInt:10],	@"statusInterval",    //every 10 sec
								 nil];
	
    [defaults registerDefaults:appDefaults];
	
}
@end
