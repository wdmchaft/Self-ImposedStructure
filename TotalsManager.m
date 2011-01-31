//
//  GoalManager.m
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "TotalsManager.h"
#import "Context.h"
//
// Keeps track of (approximate) weekly and daily totals of away, work and free time
// the values are incremented using addInterval ( called frequently )
// the values are reset nightly and weekly and this class manages the necessary timers
//
@implementation TotalsManager
@synthesize dailyRolloverTimer, rolloverDay;
@synthesize awayToday, workToday, freeToday;
@synthesize awayWeek, workWeek, freeWeek;
@synthesize interval;

- (void) dailyRollover: (NSTimer*) timer
{
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"yyyyMMdd hh:mm" ];
	NSString *todayStr = [compDate stringFromDate:timer.fireDate];
	NSLog(@"rolling over @ %@", todayStr);
	NSTimeInterval next = 24 * 60 * 60;
	// if we are called the first time then set up the loop for every 24 hours
	if (timer.userInfo){
		dailyRolloverTimer = [NSTimer scheduledTimerWithTimeInterval:next
															  target:self
															selector: @selector(dailyRollover:) 
															userInfo:[[NSDate alloc]initWithTimeIntervalSinceNow:0]
															 repeats:YES];
	}
	awayToday = workToday = freeToday = 0;
	
	// Get the weekday component of the current date
	// and if its the rollover day.... then rollover for the week
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:timer.fireDate];	
	if (comps.weekday == rolloverDay){
		awayWeek = workWeek = freeWeek = 0;
	}
}

- (NSTimer*) getTimerForRollHour: (int) rollHour
{
	NSDate *today = [[NSDate alloc] init];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	int ALLCOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
	// Get the weekday component of the current date
	NSDateComponents *rollComps = [gregorian components:ALLCOMPS fromDate:today];
	rollComps.hour = rollHour;
	rollComps.day += 1;
	NSDate *rollDate = [gregorian dateFromComponents:rollComps];
	NSTimeInterval rollInterval = [rollDate timeIntervalSinceNow];
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"yyyy-MM-dd hh:mm" ];
	NSString *rollStr = [compDate stringFromDate:rollDate];
	int hour = rollInterval / 3600; 
	int min = (((int)rollInterval) % 3600) / 60;
	NSLog(@"First Rollover is at %@, %f seconds (%d:%d) from now", rollStr, rollInterval, hour, min);
	return [NSTimer scheduledTimerWithTimeInterval:rollInterval
											target:self
										  selector: @selector(dailyRollover:) 
										  userInfo:nil
										   repeats:NO];
}

- (id) init
{
	if (self)
	{
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		NSNumber *temp = [ud objectForKey:@"DailyRolloverHour"]; // defaults to zero (aka midnight)
		int rolloverHour = temp ? [temp intValue] : 0;
		temp = [ud objectForKey:@"WeeklyRolloverDay"];
		rolloverDay = temp ? [temp intValue] + 1 : 1; //  defaults to 1 (aka sunday using NSCalendar)
		temp = [ud objectForKey:@"StatusInterval"]; 
		interval = temp ? [temp intValue] : 15;
		dailyRolloverTimer = [self getTimerForRollHour: rolloverHour];
	}
	return self;
}


- (void) addInterval:(WPAStateType) state
{
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
}
@end
