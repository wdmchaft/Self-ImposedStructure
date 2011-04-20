//
//  VacationDialog.m
//  Self-Imposed Structure
//
//  Created by Charles on 4/11/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "VacationDialog.h"


@implementation VacationDialog
@synthesize endPicker;
@synthesize onVacation;

-(void) windowDidLoad
{
	NSDate *now = [NSDate date];
	[endPicker setMinDate: now];
	// if now is before the end of vacation? - if so use the end date

	[endPicker setDateValue:[NSDate date]];
	
}

- (void) clickOk:(id)sender
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	int TIMECOMPS = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	int ALLCOMPS = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | TIMECOMPS;
	NSDateComponents *vacationComponents = [cal components:ALLCOMPS fromDate:[endPicker dateValue]];
	vacationComponents.hour = 0;
	vacationComponents.minute = 0;
	vacationComponents.second = 0;
	NSDate *vacationEndDate = [cal dateFromComponents:vacationComponents];
	[[NSUserDefaults standardUserDefaults] setObject:vacationEndDate forKey:@"vacationEndDate"];
	onVacation = YES;
	[NSApp stopModal];
	[self close];
}

- (void) clickCancel:(id)sender
{
	onVacation = NO;
	[NSApp stopModal];
	[self close];
}

@end
