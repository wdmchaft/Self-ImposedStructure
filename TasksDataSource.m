//
//  TasksDataSource.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/26/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "TasksDataSource.h"
#import "WPADelegate.h"

@implementation TDRec

@synthesize task, project, duration, complete;

@end

@implementation TasksDataSource
@synthesize data;
@synthesize format;

- (void) runQueryStarting: (NSDate*) start ending: (NSDate*) end withContext: (NSManagedObjectContext *) moc
{
    
//	[busy setHidden:NO];
//	[busy startAnimation:self];
    WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication]delegate];
    [del.ioHandler performSelector:@selector(doFlush) onThread:del.ioThread withObject:nil waitUntilDone:YES];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"CompleteTask"
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
//	NSPredicate *predicate =
    //   [NSPredicate predicateWithFormat:@"date >= %@ && date <= %@", start,end];
//    [NSPredicate predicateWithFormat:@"completeDate >= %@", start,end];
//	[request setPredicate:predicate];
    	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	data = [NSMutableArray arrayWithCapacity:[array count]];
	for (NSManagedObject *rec in array){
		TDRec *row = [TDRec new];
		row.task = (NSString*)[rec valueForKey:@"name"];
        
        NSManagedObject *proj = [row valueForKey:@"project"];
		row.project = [proj valueForKey:@"name"];
		row.duration = [rec valueForKey:@"total"];
		row.complete = [rec valueForKey:@"completeTime"];
		[data addObject: row];
	}
}

- (id) init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}
#define SECSPERMIN 60
#define MINPERHR 60
#define HRPERDAY 24
#define DAYPERWK 7

-(NSString*) formatTimePeriod: (NSTimeInterval) interval
{
	NSUInteger secs = interval;
	NSUInteger mins = secs / SECSPERMIN;
	NSUInteger hrs = mins / MINPERHR;
	NSUInteger days = hrs / HRPERDAY;
	NSUInteger wks = days / DAYPERWK;
	NSString *weekStr = [[NSString alloc] initWithFormat:@"Week"];
	NSString *weeksStr = [[NSString alloc] initWithFormat:@"Weeks"];
	NSString *daysStr = [[NSString alloc] initWithFormat:@"Days"];
	NSString *dayStr = [[NSString alloc] initWithFormat:@"Day"];
	NSString *hoursStr = [[NSString alloc] initWithFormat:@"hrs"];
	NSString *hourStr = [[NSString alloc] initWithFormat:@"hr"];
	NSString *minsStr = [[NSString alloc] initWithFormat:@"min"];
	//	NSString *minStr = [[NSString alloc] initWithFormat:@"min"];
	NSString *retStr = [NSString new];
	if (wks > 1) {
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",wks, weeksStr,days, daysStr];
	}
	if (wks == 1) {
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",wks, weekStr,days, daysStr];
	}
	if (days > 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",days, daysStr,hrs, hoursStr];
	}
	if (days == 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",days, dayStr,hrs, hoursStr];
	}
	if (hrs > 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",hrs , hoursStr,mins, minsStr];
	}
	if (hrs == 1){
		retStr = [[NSString alloc] initWithFormat:@"%d %@, %d %@",hrs , hourStr, mins, minsStr];
	}
	retStr = [[NSString alloc] initWithFormat:@"%d %@", mins, minsStr];
	return retStr;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
#if DEBUG
	NSLog(@"count = %d", [data count]);
#endif
	return [data count];
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
	NSParameterAssert(data != nil);
	NSParameterAssert(row >= 0 && row < [data count]);
	
	NSString *colName = [tableColumn identifier];
	TDRec *rec = [data objectAtIndex:row];
	if ([colName isEqualToString:@"TASK"]){
		theValue = rec.task;
	} else if ([colName isEqualToString:@"PROJECT"]){
		theValue = rec.project;
	} else if ([colName isEqualToString:@"DURATION"]){
		theValue = [self formatTimePeriod:[rec.duration doubleValue]];
	} else if ([colName isEqualToString:@"WHEN"]){
		if (format == nil){
			format = [[NSDateFormatter alloc]initWithFormat:@"EEE"];
		}
		theValue = [format stringFromDate:rec.complete];
	}
    return theValue;
}

@end
