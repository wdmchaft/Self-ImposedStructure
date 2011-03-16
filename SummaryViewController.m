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
#import "HeatMap.h"
#import "Context.h"

@implementation SummaryViewController
@synthesize table;
@synthesize prog;
@synthesize reporter;
@synthesize data;
@synthesize maxLines;
@synthesize boldFont;
@synthesize actualLines; 
@synthesize caller;
@synthesize width;

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
	[table setAction:@selector(handleAction:)];
	[table setTarget:self];

	NSRect frame;
    frame.size.height = [self actualHeight];
    frame.size.width = width;
    frame.origin.x = 0; frame.origin.y = 0;
    [table setFrame:frame];
	[table display];
	[self initTable];	
}


- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
			   module: (id<Reporter>) report 
				 rows: (int) maxRows
             waitRows: (int) waitRows
                width:(int) widthIn
			   caller: (id<SummaryHUDCallback>) callback 
{
	self = [super initWithNibName:nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
		reporter = report;
		caller = callback;
		maxLines = maxRows;
		actualLines = waitRows;
        width = widthIn;
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
		actualLines = [data count];
		[caller viewSized];
		
	}
	else {
		if (!data){
			data = [NSMutableArray new];
		}
		[data addObject: alert.params];
		[table noteNumberOfRowsChanged];
	}
}

- (void) handleAction: (id) sender
{
	NSLog(@"handleAction");
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
	[((id<TaskList>)reporter) markComplete:params completeHandler:self];
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

- (void) handleDouble: (id) sender{}

- (NSDictionary*) readAttributes
{
	if (!boldFont){
		float fontSize = [NSFont systemFontSizeForControlSize:NSSmallControlSize]; 
		NSFont *font = [NSFont controlContentFontOfSize:fontSize];
		NSFontManager *fontManager = [NSFontManager sharedFontManager];
		boldFont =[fontManager convertFont:font toHaveTrait:NSBoldFontMask];
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:boldFont, NSFontAttributeName,[NSColor redColor], NSForegroundColorAttributeName, nil];
}

- (NSDictionary*) attributesForInterval: (NSTimeInterval) interval
{
//	float fontSize = [NSFont systemFontSizeForControlSize:NSSmallControlSize]; 
//	NSFont *font = [NSFont controlContentFontOfSize:fontSize];
	HeatMap *map = [Context sharedContext].heatMapSettings;
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[map colorForInterval:interval], NSForegroundColorAttributeName, nil];
}

- (int) actualHeight
{
	int lines = (actualLines > maxLines) ? maxLines :actualLines;
    int rowHeight = [table rowHeight];
	return lines * ([table rowHeight] + 3);
}

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
	NSDate *starts = [params objectForKey:@"start"];
	NSTimeInterval intv = [starts timeIntervalSinceNow];
	NSDictionary *attrs = [self attributesForInterval: intv];
	if ([colName isEqualToString:@"COL1"]){
		theValue = [Utility shortTimeStrFor:starts];
	} else {
		theValue = [params objectForKey:EVENT_SUMMARY];
	}
	theValue = [[NSAttributedString alloc]initWithString:(NSString*)theValue attributes: attrs];
    return theValue;
}

- (void) initTable{}


- (void) handleDouble: (id) sender;
{
	int row = [sender selectedRow];
	
	NSDictionary *ctx = [data objectAtIndex:row];	
	[reporter handleClick:ctx];
}
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
	NSDate *due = (NSDate*) [params objectForKey:@"due_time"];
	if ([colId isEqualToString:@"COL1"]){
		NSString *val;
		val = (NSString*)[params objectForKey:TASK_NAME];
		if (![due isEqualToDate:[NSDate distantFuture]]){
			NSLog(@"got val = %@", val);
			val = [NSString stringWithFormat:@"%@ : %@",[Utility shortTimeStrFor:due], val];
		}
		theValue = val;
	} else {
		theValue = [NSNumber numberWithInt: 0];
	}
	if ([theValue isKindOfClass:[NSString class]] && due){
		NSTimeInterval intv = [due timeIntervalSinceNow];
		NSDictionary *attrs = [self attributesForInterval: intv];
		NSLog(@"val = %@",(NSString*)[params objectForKey:TASK_NAME]);
		theValue = [[NSAttributedString alloc]initWithString:(NSString*)theValue attributes: attrs];
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


- (void) handleDouble: (id) sender;
{
	int row = [sender selectedRow];
	
	NSDictionary *ctx = [data objectAtIndex:row];	
	[reporter handleClick:ctx];
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
	BOOL readStatus = [((NSNumber*)[params objectForKey:@"readStatus"]) boolValue];
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
	if (!readStatus){
		theValue = [[NSAttributedString alloc]initWithString:theValue attributes:[self readAttributes]];
	}
    return theValue;
}
- (void) initTable{}

- (void) handleDouble: (id) sender;
{
	int row = [sender selectedRow];
	
	NSDictionary *ctx = [data objectAtIndex:row];	
	[reporter handleClick:ctx];
}

- (void) handleAction: (id) sender
{
	NSLog(@"handleAction - mail");
}

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