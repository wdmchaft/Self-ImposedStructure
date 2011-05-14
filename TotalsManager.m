//
//  TotalsManager.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
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
@synthesize dailyRolloverTimer, rolloverDay, rolloverTime, timeStampDate;
@synthesize awayToday, workToday, freeToday;
@synthesize awayWeek, workWeek, freeWeek;
@synthesize interval, recordChecked, summary;
@synthesize rollDelegate;

- (void) initFromRecord
{
	WPADelegate *del = (WPADelegate*)[NSApplication sharedApplication].delegate;
	NSTimeInterval work = 0;
	NSTimeInterval free = 0;
	if ([del findSummaryForDate:timeStampDate work:&work free:&free]){
        freeToday += free;
        workToday += work;
        Context *ctx = [Context sharedContext];
        [[ctx growlManager] growlThis:@"Welcome back (I hope we didn't crash)!" isSticky:YES withTitle:@"Hey Again"];
    } else {
        Context *ctx = [Context sharedContext];
        [[ctx growlManager] growlThis:@"Welcome to a new day!" isSticky:YES withTitle:@"Hey There"];
    }
    summary = [del.ioHandler getSummaryRecord];
    
}

- (void) setVacationEnd: (NSDate*) date
{
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"vacationEndDate"];
}

- (BOOL) isVacationToday
{
	NSDate *vacationEnd = [[NSUserDefaults standardUserDefaults] objectForKey:@"vacationEndDate"];
	// if now is before the end of vacation?
	// the timestamp date is "now"
	return ([timeStampDate compare: vacationEnd] == NSOrderedAscending);
}

- (double) calcGoal
{
    if ([self isVacationToday])
        return 0;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSWeekdayCalendarUnit fromDate:timeStampDate];
    NSUInteger day = [comps weekday];
    NSString *defaultKey = [NSString stringWithFormat:@"day%dGoal",day - 1]; //gregorian day ordinals 1-7
    return [[NSUserDefaults standardUserDefaults] doubleForKey:defaultKey];
}

- (void)saveCurrent
{
	[WriteHandler sendTotalsForDate:timeStampDate 
                               goal:[self calcGoal]
                               work:workToday 
                               free:freeToday];
    [WriteHandler sendSummary:summary]; 
}

- (void) saveActivity 
{
    [WriteHandler sendActivity: timeStampDate
                      activity:[Context sharedContext].currentTask
                     increment:interval];
}

- (BOOL) isFromToday:(NSDate*) dateIn
{
	NSDate *today = timeStampDate;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	int DAYCOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	// Get the weekday component of the current date
	NSDateComponents *todayComps = [gregorian components:DAYCOMPS fromDate:today];
	NSDateComponents *inComps = [gregorian components:DAYCOMPS fromDate:dateIn];
    
    if (todayComps.day != inComps.day)
        return NO;
    if (todayComps.month != inComps.month)
        return NO;
    if (todayComps.year != inComps.year)
        return NO;

    return YES;
}


- (void) updateSummaryWithWork: (NSTimeInterval) workTime 
                          free: (NSTimeInterval) freeTime 
                          away: (NSTimeInterval) awayTime 
{
    NSUInteger oldTotal = summary.daysTotal.intValue;
    [summary setDaysTotal:[NSNumber numberWithInt:++oldTotal]];
    double goalTime = [self calcGoal];

    /*
     updating the days counters should only happen once per day.
     */
    if (workToday > 0.0){
        if (![self isFromToday:summary.lastDay]) {
            NSUInteger oldWorkDays = summary.daysWorked.intValue;
            [summary setDaysWorked:[NSNumber numberWithInt:++oldWorkDays]]; 
            [summary setLastDay:timeStampDate];
        }
      
        if (![self isFromToday:summary.lastWorked]) {   
            NSTimeInterval oldTimeWorked = summary.timeWorked.doubleValue;
            [summary setTimeWorked:[NSNumber numberWithDouble:(oldTimeWorked + workTime)]];
            [summary setLastWorked:timeStampDate];
        }
        
        if (![self isFromToday:summary.lastGoalAchieved]) {   
            if (workToday > goalTime){
                NSUInteger oldGoalHit = summary.daysGoalAchieved.intValue;
                [summary setDaysGoalAchieved:[NSNumber numberWithInt:++oldGoalHit]];         
                NSTimeInterval oldGoal = summary.timeGoal.doubleValue;
                [summary setTimeGoal:[NSNumber numberWithDouble:(oldGoal + goalTime)]];
                [summary setLastGoalAchieved:timeStampDate];
                Context *ctx = [Context sharedContext];
                [[ctx growlManager] growlThis: @"Work day is done!" isSticky:YES withTitle:@"Whew!"];
                [rollDelegate gotDone];
            }
        }

    }
    

    /** wnat to do about total time for real? **/
    NSTimeInterval oldTimeTotal = summary.timeTotal.doubleValue;
    [summary setTimeTotal:[NSNumber numberWithDouble:(oldTimeTotal + freeTime + freeTime + awayTime)]];

}

- (void) dailyRollover: (NSTimer*) timer
{
	NSDateFormatter *compDate = [NSDateFormatter new];
	[compDate  setDateFormat:@"yyyyMMdd hh:mm" ];
	NSString *todayStr = [compDate stringFromDate:timer.fireDate];
	//NSLog(@"rolling over @ %@", todayStr);
	NSTimeInterval next = 24 * 60 * 60;
	// if we are called the first time then set up the loop for every 24 hours
	if (timer.userInfo == nil){
		dailyRolloverTimer = [NSTimer scheduledTimerWithTimeInterval:next
															  target:self
															selector: @selector(dailyRollover:) 
															userInfo:[[NSDate alloc]initWithTimeIntervalSinceNow:0]
															 repeats:YES];
	}
    
    [self updateSummaryWithWork:workToday free:freeToday away:awayToday];
    
	// write a record
	[self saveCurrent];
	timeStampDate = [timeStampDate dateByAddingTimeInterval:24 * 60 * 60];
	
	// Get the weekday component of the current date
	// and if its the rollover day.... then rollover for the week
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	awayToday = workToday = freeToday = 0;

	NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:timer.fireDate];	
	if (comps.weekday == rolloverDay){
		awayWeek = workWeek = freeWeek = 0;
	}
    Context *ctx = [Context sharedContext];
    [[ctx growlManager] growlThis:@"Starting a new day!" isSticky:YES withTitle:@"Hey There!"];
	[rollDelegate gotRollover];
}

- (void) dumpRollDate: (NSDate*) rollDate andInterval: (NSTimeInterval) rollInterval
{
	NSDateFormatter *compDate = [NSDateFormatter new];
	[compDate  setDateFormat:@"yyyy-MM-dd HH:mm" ];
	NSString *rollStr = [compDate stringFromDate:rollDate];
	int hour = rollInterval / 3600; 
	int min = (((int)rollInterval % 3600) / 60);
	int sec = (((int)rollInterval) % 60);
	//NSLog(@"First Rollover is at %@, %f seconds (%02d:%02d:%02d) from now", rollStr, rollInterval, hour, min, sec);
}

- (NSTimer*) getTimerAndStampForRollover: (NSDate*) rollDate
{
	NSDate *now = [NSDate date];
	int TIMECOMPS = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	int ALLCOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | TIMECOMPS;
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	NSDateComponents *nowComps = [gregorian components:ALLCOMPS fromDate:now];
	
	NSDateComponents *rollComps = [gregorian components:ALLCOMPS fromDate:rollDate];
	
	nowComps.hour = rollComps.hour;
	nowComps.minute = rollComps.minute;
	nowComps.second = rollComps.second;
	NSDate *rollToday = [gregorian dateFromComponents:nowComps];
	
	NSTimeInterval rollInterval = [rollToday timeIntervalSinceNow];
	BOOL afterRolltime = (rollInterval < 0);
	if (afterRolltime){ // the roll time is earlier than now
		nowComps.day += 1;
		rollToday = [gregorian dateFromComponents:nowComps];
	}
	rollInterval = [rollToday timeIntervalSinceNow];
	[self dumpRollDate: rollToday andInterval: rollInterval];
	// now calc the timestamp date
	
	NSDateComponents *timeStampComps = [gregorian components:ALLCOMPS fromDate:now];
	timeStampComps.hour = 0;
	timeStampComps.minute = 0;
	timeStampComps.second = 0;
	if (afterRolltime == NO){
		timeStampComps.day -= 1;
	}
	timeStampDate = [gregorian dateFromComponents:timeStampComps];
	
	// now remove milliseconds from the timestamp date
	NSTimeInterval temp = [timeStampDate timeIntervalSinceReferenceDate];
	temp = floor(temp);
	timeStampDate = [NSDate dateWithTimeIntervalSinceReferenceDate:temp];

	return [NSTimer scheduledTimerWithTimeInterval:rollInterval
											target:self
										  selector: @selector(dailyRollover:) 
										  userInfo:nil
										   repeats:NO];
}

- (NSDate*) getTimeStampDate: (double) rollTimeSecs
{
	NSDate *today = [NSDate date];

	NSCalendar *gregorian = [NSCalendar currentCalendar];
	int ALLCOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |
				   NSMinuteCalendarUnit | NSSecondCalendarUnit;
	// Get the weekday component of the current date
	NSDateComponents *rollComps = [gregorian components:ALLCOMPS fromDate:today];
	int nowSecs = rollComps.second + (rollComps.minute * 60) + (rollComps.hour * 3600);
	if (rollTimeSecs > nowSecs){
		rollComps.day -= 1;
	}

	
	NSDate *stamp = [gregorian dateFromComponents:rollComps];
 //   [stamp timeIntervalSinceNow];
 //   NSDateFormatter *fmt = [NSDateFormatter new];
 //   [fmt setDateFormat:@"MM/dd HH:mm:SSSSS"];
 //   //NSLog(@"stamp = %@", [fmt stringFromDate:stamp]);
	return stamp;
}

- (id) init
{
	if (self)
	{
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		rolloverTime = [ud objectForKey:@"dailyRolloverTime"]; // defaults to zero (aka midnight)
		//NSLog(@"rollover time: %@", rolloverTime);
		rolloverDay =  ((NSNumber*)[ud objectForKey:@"weeklyRolloverDay"]).intValue;
		interval = ((NSNumber*)[ud objectForKey:@"statusInterval"]).doubleValue; 
		dailyRolloverTimer = [self getTimerAndStampForRollover: rolloverTime];
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
			[self updateSummaryWithWork:workToday free:freeToday away:awayToday];
			break;
			
		default:
			break;
	}
	[self saveCurrent];
    if (state == WPASTATE_THINKING){
        [self saveActivity];
    }
}

+ (void) initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *rollDate = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	int TIMECOMPS = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *dateComps = [cal components:TIMECOMPS fromDate:rollDate];
	dateComps.hour = 0;
	dateComps.minute = 0;
	dateComps.second = 0;
	rollDate = [cal dateFromComponents:dateComps];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:0],	@"day0Goal", //sunday
								 [NSNumber numberWithInt:8 * 60 * 60],	@"day1Goal", //monday
								 [NSNumber numberWithInt:8 * 60 * 60],	@"day2Goal", //tues
								 [NSNumber numberWithInt:8 * 60 * 60],	@"day3Goal", //wed
								 [NSNumber numberWithInt:8 * 60 * 60],	@"day4Goal", //thu
								 [NSNumber numberWithInt:8 * 60 * 60],	@"day5Goal", //fri
								 [NSNumber numberWithInt:0],	@"day6Goal", //sat
								 rollDate, @"dailyRolloverTime", //midnight
								 [NSNumber numberWithInt:1],	@"weeklyRolloverDay", //sunday
								 [NSNumber numberWithInt:10],	@"statusInterval",    //every 10 sec
								 nil];
	
    [defaults registerDefaults:appDefaults];
	
}
@end
