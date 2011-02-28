//
//  SummaryViewController.m
//  WorkPlayAway
//
//  Created by Charles on 2/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryViewController.h"
#import "Utility.h"
#import <BGHUDAppKit/BGHUDAppKit.h> 
#import "TaskList.h"

@implementation SummaryViewController
@synthesize table;
@synthesize prog;
@synthesize reporter;
@synthesize data;
@synthesize size;
-(void) awakeFromNib
{
	table.dataSource=self;
	[table setDoubleAction:@selector(handleDouble:)];
}

- (void) loadView
{
	[super loadView];
	table.dataSource=self;
	NSLog(@"table = %@", table);
	[table setDoubleAction:@selector(handleDouble:)];

	NSRect frame;
	size.height -= 10;
	frame.size = size;
	frame.origin.x = 0; frame.origin.y = 0;
	[table setFrame:frame];
	[table display];
	[self initTable];	
}


- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
			   module: (<Reporter>) report 
				 size: (NSSize) pt
{
	self = [super initWithNibName:nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
		reporter = report;
		size = pt;
    }
    return self;
}

- (void) refresh
{
	NSLog(@"refresh!");
	data = nil;
	[prog setHidden:NO];
	[prog startAnimation:self];
	[reporter refresh: self];
}


-(void) handleError: (Note*) error
{
	[prog setHidden:YES];
	[prog stopAnimation:self];
}	
- (void) handleAlert: (Note*) alert
{
	if (alert.lastAlert){
		[prog setHidden:YES];
		[prog stopAnimation:self];
	}
	else {
		if (!data){
			data = [NSMutableArray new];
		}
		[data addObject: alert.params];
		[table noteNumberOfRowsChanged];
	}
}


- (void) handleDouble: (id) sender;
{
	int row = [sender selectedRow];
	
	NSDictionary *ctx = [data objectAtIndex:row];	
	[reporter handleClick:ctx];
}

- (IBAction) checkTask: (id) sender
{
	int row = [sender selectedRow];	
	NSDictionary *params = [data objectAtIndex:row];
	[prog setHidden:NO];
	[prog startAnimation:self];
	[NSTimer scheduledTimerWithTimeInterval:0
									 target:self
								   selector:@selector(processComplete:) 
								   userInfo: params
									repeats:NO];
}

- (void) processComplete: (NSTimer*)timer
{	
	NSDictionary* params = timer.userInfo;
	[((<TaskList>)reporter) markComplete:params completeHandler:self];
}

- (void) handleComplete: (NSString*) error
{
	[prog stopAnimation:self];
	[prog setHidden:YES];
	
	[data removeAllObjects];
	[reporter refresh:self];
	[table deselectAll:self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSInteger ret = [data count];
	//NSLog(@"count = %d", ret);
	return ret;
}

- (void) initTable{}

@end

@implementation SummaryEventViewController

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
	NSParameterAssert(row >= 0 && row < [data count]);
	if (row == 0){
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
		[data sortUsingDescriptors:[NSArray arrayWithObject:desc]];
	}
    NSDictionary *params  = [data objectAtIndex:row];
	NSString *colName = [tableColumn identifier];
	if ([colName isEqualToString:@"COL1"]){
		NSDate *starts = [params objectForKey:@"start"];
		theValue = [Utility shortTimeStrFor:starts];
	} else {
		theValue = [params objectForKey:EVENT_SUMMARY];
	}
	
	
    return theValue;
}
- (void) initTable{}
@end

@implementation SummaryTaskViewController

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [data count]);
	if (row == 0){
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"due_time" ascending:YES];
		[data sortUsingDescriptors:[NSArray arrayWithObject:desc]];
	}
	NSDictionary *params  = [data objectAtIndex:row];
	NSString *colId = [tableColumn identifier];
	if ([colId isEqualToString:@"COL1"]){
		NSString *val;
		NSDate *due = (NSDate*) [params objectForKey:@"due_time"];
		val = (NSString*)[params objectForKey:TASK_NAME];
		if (![due isEqualToDate:[NSDate distantFuture]]){
			NSLog(@"got val = %@", val);
			val = [NSString stringWithFormat:@"%@ : %@",[Utility shortTimeStrFor:due], val];
		}
		theValue = val;
	} else {
		theValue = [NSNumber numberWithInt: 0];
	}
    return theValue;
}

- (void) initTable
{

	NSArray *allCols = table.tableColumns;
	NSTableColumn *col1 = [allCols objectAtIndex:0];

    BGHUDButtonCell *cell;
	cell = [[NSButtonCell alloc] init];
	[cell setButtonType:NSSwitchButton];
	[cell setTitle:@""];
	[cell setAction:@selector(checkTask:)];
	[cell setTarget:self];

	[col1 setDataCell:cell];
	[cell release];
}


@end

@implementation SummaryMailViewController

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [data count]);
	if (row == 0){
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:MAIL_ARRIVAL_TIME ascending:NO];
		[data sortUsingDescriptors:[NSArray arrayWithObject:desc]];
	}
    NSDictionary *params  = [data objectAtIndex:row];
	NSString *colName = [tableColumn identifier];
	if ([colName isEqualToString:@"COL1"])
	{
		theValue = [params objectForKey:MAIL_EMAIL];
	}
	else if  ([colName isEqualToString:@"COL2"]){
		NSDate *due = (NSDate*) [params objectForKey:MAIL_ARRIVAL_TIME];
		theValue = [Utility shortTimeStrFor:due];
	} else {
		theValue = [params objectForKey:MAIL_SUBJECT];
	}
    return theValue;
}
- (void) initTable{}
@end

@implementation SummaryDeadlineViewController

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [data count]);
	if (row == 0){
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"due_time" ascending:NO];
		[data sortUsingDescriptors:[NSArray arrayWithObject:desc]];
	}
    NSDictionary *params  = [data objectAtIndex:row];
	NSString *colName = [tableColumn identifier];
	if ([colName isEqualToString:@"COL1"])
	{
		theValue = [NSNumber numberWithInt:0];
	}
	else if  ([colName isEqualToString:@"COL2"]){
		NSDate *due = (NSDate*) [params objectForKey:@"due_time"];
		theValue = [Utility shortTimeStrFor:due];
	} else {
		theValue = [params objectForKey:@"name"];
	}
	
	return theValue;
}

- (void) initTable
{
	
	NSArray *allCols = table.tableColumns;
	NSTableColumn *col1 = [allCols objectAtIndex:0];
	
    BGHUDButtonCell *cell;
	cell = [[NSButtonCell alloc] init];
	[cell setButtonType:NSSwitchButton];
	[cell setTitle:@""];
	[cell setAction:@selector(checkTask:)];
	[cell setTarget:self];
	
	[col1 setDataCell:cell];
	[cell release];
}
@end