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

+(NSString*) entityNameForState:(int) state
{
	switch (state) {
		case STATE_THINKTIME:
		case STATE_THINKING:
			return @"Work";
			break;
		case STATE_AWAY:
			return @"Away";
			break;
		case STATE_PUTZING:
			return @"Free";
			break;
		case STATE_OFF:
		default:
			return nil;
	}
}

+ (void) newRecord: (int) state
{
	Context *ctx = [Context sharedContext];
	WPADelegate *del = (WPADelegate*)[NSApplication sharedApplication].delegate;
	if (ctx.currentActivity != nil){
		NSDate *start = [ctx.currentActivity valueForKey:@"startTime"];
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		[ctx.currentActivity setValue:[NSNumber numberWithInt:interval] forKey:@"interval"];
		NSLog(@"Done with %@% interval: %f", [self dumpMObj:ctx.currentActivity], interval);
	} else {
		NSLog(@"No Current Activity");
	}
	// new work record
	NSManagedObjectContext *moc = [del managedObjectContext];
	NSManagedObject *task = nil;
	NSString *newTask = ctx.currentTask == nil ? @"[No Task]" : ctx.currentTask;		
	
	if (state == STATE_THINKING || state == STATE_THINKTIME){
		task = [Schema findTask: newTask inContext: moc];
		if (task == nil){
			task = [NSEntityDescription
					insertNewObjectForEntityForName:@"Task"
					inManagedObjectContext:moc];
			[task setValue:[NSDate date] forKey: @"createTime"];
			[task setValue:newTask forKey: @"name"];
			
		}
	}
	NSString *entityName = [Schema entityNameForState:state];
	if (entityName != nil) {
		NSManagedObject *newActivity = [NSEntityDescription
										insertNewObjectForEntityForName:entityName
										inManagedObjectContext:moc];
		if ([self hasTask:newActivity] && task != nil){
			[newActivity setValue:task forKey:@"task"];
		}
		[newActivity setValue: [NSDate date] forKey:@"startTime"];	
		[newActivity setValue: @"" forKey:@"notes"];
		ctx.currentActivity = newActivity;
		NSLog(@"Starting %@", [self dumpMObj:ctx.currentActivity]);
	}
	else {
		ctx.currentActivity = nil;
	}
}

@end
