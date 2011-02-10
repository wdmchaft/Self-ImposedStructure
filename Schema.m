//
//  Schema.m
//  WorkPlayAway
//
//  Created by Charles on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Schema.h"
#import "State.h"
#import "WPADelegate.h"
#import "TimeDefines.h"
#import "StatsRecord.h"

@implementation Schema

+(NSArray*) rowsForDate: (NSString*) name inContext: (NSManagedObjectContext*) moc endDate: (NSDate*) date
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:name
				inManagedObjectContext:moc];
	[request setEntity:entity];
	NSTimeInterval THIRTYDAYS = SECSPERMIN * MINPERHR *HRPERDAY * 30;
	NSDate *oneMonth = [date dateByAddingTimeInterval:(-THIRTYDAYS)];
	
//	NSPredicate *predicate =
  //  [NSPredicate predicateWithFormat:@"endTime > %@", oneMonth];
//	[request setPredicate:predicate];
	
	NSError *error = nil;
	return[moc executeFetchRequest:request error:&error];
	
}

+ (NSArray*) statsReportForDate :(NSDate*) date inContext: (NSManagedObjectContext*)moc
{
	NSArray *typeArray = [[NSArray alloc]initWithObjects:@"Free",@"Work",@"Away",nil ];
	NSMutableArray *retArray = [[NSMutableArray alloc]initWithCapacity:[typeArray count]];
	NSTimeInterval ONEHOUR =SECSPERMIN * MINPERHR;
	NSTimeInterval ONEDAY = ONEHOUR *HRPERDAY;
	NSTimeInterval THIRTYDAYS = ONEDAY * 30;
	NSTimeInterval SEVENDAYS = ONEDAY * 7;
	NSDate *oneMonth = [date dateByAddingTimeInterval:(-THIRTYDAYS)];
	NSDate *oneWeek = [date dateByAddingTimeInterval:(-SEVENDAYS)];
	NSDate *oneDay = [date dateByAddingTimeInterval:(-ONEDAY)];
	NSDate *oneHour = [date dateByAddingTimeInterval:(-ONEHOUR)];
	
	for (NSString* activity in typeArray){
		StatsRecord *record = [[StatsRecord alloc]initWithName:activity];
		NSArray *allRows = [Schema rowsForDate:record.activity inContext:moc endDate:oneMonth];
		[Schema fetchIntoRecord:record fromArray:allRows 
					  usingWeek: oneWeek usingDay: oneDay usingHour: oneHour];
		[retArray addObject:record];
	}
	return retArray;
}

+ (NSArray*) fetchWorkReportForMonth: (NSDate*) date
			inContext: (NSManagedObjectContext*)moc
{
	NSTimeInterval ONEHOUR =SECSPERMIN * MINPERHR;
	NSTimeInterval ONEDAY = ONEHOUR *HRPERDAY;
	NSTimeInterval THIRTYDAYS = ONEDAY * 30;
	NSTimeInterval SEVENDAYS = ONEDAY * 7;
	NSDate *oneWeek = [date dateByAddingTimeInterval:(-SEVENDAYS)];
	NSDate *oneDay = [date dateByAddingTimeInterval:(-ONEDAY)];
	NSDate *oneHour = [date dateByAddingTimeInterval:(-ONEHOUR)];
	NSDate *oneMonth = [date dateByAddingTimeInterval:(-THIRTYDAYS)];
	
	NSArray *allRows = [Schema rowsForDate:@"Work" inContext:moc endDate:oneMonth];
	NSMutableDictionary *rowDict = [NSMutableDictionary new];

	for (NSManagedObject *obj in allRows)
	{
		NSManagedObject *task = [obj valueForKey: @"task"];
		NSManagedObject *source = [task valueForKey:@"source"];
		StatsRecord *record = [[StatsRecord alloc]initWithName:@"Work"];
		record.task =[task valueForKey:@"name"];
		record.source = source == nil ? @"ad hoc" : [source valueForKey:@"name"];
		NSString *rowKey = record.key;
		StatsRecord *test =  (StatsRecord*) [rowDict objectForKey:rowKey];
		if (test == nil){
			[rowDict setObject:record forKey:rowKey];
		}
		else {
			record = test;
		}
		
		NSNumber *interval = [obj valueForKey: @"interval"];
		 

		NSDate *endDate = [obj valueForKey:@"endTime"];	
		if (endDate){
			NSTimeInterval maxInt = [endDate timeIntervalSinceDate:oneMonth];
			double cumIncr = maxInt < [interval doubleValue] ? maxInt : [interval doubleValue];
			record.month += [interval doubleValue];
			
			if ([endDate compare:oneWeek] == NSOrderedDescending){
				maxInt = [endDate timeIntervalSinceDate:oneWeek];
				cumIncr = maxInt < [interval doubleValue] ? maxInt : [interval doubleValue];
				record.week += cumIncr;
			}
			if ([endDate compare:oneDay] == NSOrderedDescending){
				NSTimeInterval maxInt = [endDate timeIntervalSinceDate:oneDay];
				double cumIncr = maxInt < [interval doubleValue] ? maxInt : [interval doubleValue];
				record.today += cumIncr;
			}
			if ([endDate compare:oneHour] == NSOrderedDescending){
				NSTimeInterval maxInt = [endDate timeIntervalSinceDate:oneHour];
				double cumIncr = maxInt < [interval doubleValue] ? maxInt : [interval doubleValue];
				record.hour += cumIncr;
			}
		}
	}	
	NSArray *ret = [rowDict allValues];
	return ret;
}


+(double) countEntity: (NSString*) name inContext: (NSManagedObjectContext*) moc
{
	double cum = 0.0;
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:name
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	for (NSManagedObject *obj in array)
	{
		NSNumber *num = [obj valueForKey: @"interval"];
		cum += [num doubleValue];
	}
	return cum;
}

+(NSManagedObject*) findTask: (NSString*) name inContext: (NSManagedObjectContext*) moc
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Task"
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
	NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"self == %@", name];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if (array != nil && [array count] == 1) {
		return (NSManagedObject*)[array objectAtIndex:0];
	}
	else {
		return nil;
	}
}

+ (NSString*) dumpMObj: (NSManagedObject*) obj
{
	NSString *eName = [[obj entity] name];
	NSString *tName = @"No Task";
	if ([Schema hasTask:obj]){
		NSManagedObject	*task = [obj valueForKey:@"task"];
		if (task)
			tName = [task valueForKey:@"name"];
	}
	return [NSString stringWithFormat:@"%@ [%@]",eName, tName];
}

+ (BOOL) hasTask: (NSManagedObject*) mobj
{
	NSEntityDescription *desc = [mobj entity];
	NSDictionary *dict = [desc propertiesByName];
	BOOL answer = [dict objectForKey:@"task"] != nil;
	return answer;
}

+(NSString*) entityNameForState:(WPAStateType) state
{
	switch (state) {
		case WPASTATE_THINKTIME:
		case WPASTATE_THINKING:
			return @"Work";
			break;
		case WPASTATE_AWAY:
			return @"Away";
			break;
		case WPASTATE_FREE:
			return @"Free";
			break;
		case WPASTATE_OFF:
		default:
			return nil;
	}
}

+(void) fetchIntoRecord: (StatsRecord*) record 
			  fromArray: (NSArray*) array
			  usingWeek: (NSDate*) weekDate 
			   usingDay: (NSDate*) dayDate
			  usingHour: (NSDate*) hourDate
{
	double allCum = 0.0;
	double weekCum = 0.0;
	double dayCum = 0.0;
	double hourCum = 0.0;
	for (NSManagedObject *obj in array)
	{
		NSNumber *interval = [obj valueForKey: @"interval"];
		allCum += [interval doubleValue];
		NSDate *endDate = [obj valueForKey:@"endTime"]; 
		if (endDate == nil){
			NSDate *start = [obj valueForKey:@"startTime"];
			endDate = [start dateByAddingTimeInterval:[interval doubleValue]];
		}
		if (endDate){
			if ([endDate compare:weekDate] == NSOrderedDescending){
				NSTimeInterval maxInt = [endDate timeIntervalSinceDate:weekDate];
				double cumIncr = maxInt < [interval doubleValue] ? maxInt : [interval doubleValue];
				weekCum += cumIncr;
			}
			if ([endDate compare:dayDate] == NSOrderedDescending){
				NSTimeInterval maxInt = [endDate timeIntervalSinceDate:dayDate];
				double cumIncr = maxInt < [interval doubleValue] ? maxInt : [interval doubleValue];
				dayCum += cumIncr;
			}
			if ([endDate compare:hourDate] == NSOrderedDescending){
				NSTimeInterval maxInt = [endDate timeIntervalSinceDate:hourDate];
				double cumIncr = maxInt < [interval doubleValue] ? maxInt : [interval doubleValue];
				hourCum += cumIncr;
			}
		}
	}	
	record.today = dayCum;
	record.week = weekCum;
	record.hour = hourCum;
	record.month = allCum;
}

@end
