//
//  SummaryViewController.m
//  Self-Imposed Structure
//
//  Created by Charles on 2/19/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SummaryViewController.h"
#import "Utility.h"
#import <BGHUDAppKit/BGHUDAppKit.h> 
#import "TaskList.h"
#import "HeatMap.h"
#import "Context.h"
#import "WriteHandler.h"
#import "Queues.h"

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
@synthesize refreshHandler;

-(void) awakeFromNib
{
	table.dataSource=self;
	[table setDoubleAction:@selector(handleDouble:)];
}

- (void) loadView
{
	[super loadView];
	table.dataSource=self;
	////NSLog(@"table = %@", table);
	[table setDoubleAction:@selector(handleDouble:)];
	//[table setAction:@selector(handleAction:)];
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
	//NSLog(@"refresh!");
//	[data removeAllObjects];
//    [table noteNumberOfRowsChanged];
	[prog setHidden:NO];
	[prog startAnimation:self];
	[reporter refresh: self isSummary:YES useCache:YES];
}

-(void) handleError: (WPAAlert*) error
{
	[prog setHidden:YES];
	[prog stopAnimation:self];
}	

- (void) handleAlert: (WPAAlert*) alert
{
	if (alert.lastAlert){
		NSLog(@"last alert for [%@] count = %d", [reporter name], [data count]);
		[prog setHidden:YES];
		[prog stopAnimation:self];
		actualLines = [data count];
        [table reloadData];
		[caller viewSized:[self view] reporter:reporter data:data];
		
	}
	else {
		if (!data){
			data = [NSMutableArray new];
		}
		[data addObject: alert.params];
	//	[table noteNumberOfRowsChanged];
	}
}

- (IBAction) checkTask: (id) sender
{
	int row = [sender selectedRow];	
	NSDictionary *params = [data objectAtIndex:row];
  //  [data removeAllObjects];
	NSTableColumn *checkCol = [[table tableColumns] objectAtIndex:0];
    [[checkCol dataCell]setEditable:NO];
	[NSTimer scheduledTimerWithTimeInterval:0
									 target:self
								   selector:@selector(processComplete:) 
								   userInfo: params
									repeats:NO];
}

- (void) processComplete: (NSTimer*)timer
{	
	[prog setHidden:NO];
	[prog startAnimation:self];
	NSDictionary* params = timer.userInfo;
	[((id<TaskList>)reporter) markComplete:params completeHandler:self selector:@selector(handleComplete:)];
	[WriteHandler completeActivity:params atTime:[timer fireDate]];
}

- (void) handleComplete: (NSString*) error
{
	[prog stopAnimation:self];
	[prog setHidden:YES];
	Context *ctx = [Context sharedContext];
	NSString *changeQueue =  [Queues queueNameFor:WPA_COMPLETEQUEUE fromBase:ctx.queueName];
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center postNotificationName:changeQueue object:nil userInfo:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSInteger ret = [data count];
//	NSLog(@"%@ count = %d", [reporter summaryTitle], ret);
	return ret;
}

- (void) initTable{}

- (void) handleDouble: (id) sender{}

- (NSDictionary*) attributesForColor:(NSColor*) color
{
	if (!boldFont){
		float fontSize = [NSFont systemFontSizeForControlSize:NSSmallControlSize]; 
		NSFont *font = [NSFont controlContentFontOfSize:fontSize];
		NSFontManager *fontManager = [NSFontManager sharedFontManager];
		boldFont =[fontManager convertFont:font toHaveTrait:NSBoldFontMask];
	}
	return [NSDictionary dictionaryWithObjectsAndKeys:boldFont, NSFontAttributeName, color, NSForegroundColorAttributeName, nil];
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
	actualLines = [data count];
	int lines = (actualLines > maxLines) ? maxLines :actualLines;
//	int height = lines * ([table rowHeight] + 3);
//	NSLog(@"maxLines = %d actualLines = %d height = %d for %@", maxLines, actualLines, height, reporter.name);
	return lines * ([table rowHeight] + 3);
}

- (void) endRefresh {
}

@end

@implementation SummaryEventViewController

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
	NSParameterAssert(row >= 0 && row < [data count]);
	if (row == 0){
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
		[data sortUsingDescriptors:[NSArray arrayWithObject:desc]];
	}
    NSDictionary *params  = [data objectAtIndex:row];
	NSString *colName = [tableColumn identifier];
	NSDate *starts = [params objectForKey:@"start"];
	NSTimeInterval intv = [starts timeIntervalSinceNow];
	NSDictionary *attrs = [self attributesForInterval: intv];
	if ([colName isEqualToString:@"COL1"]){
		theValue = [Utility dueTimeStrFor:starts];
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
@synthesize inRefresh;

- (void) processComplete: (NSTimer*)timer
{	
    if (inRefresh){
        //NSLog(@"ignoring complete click");
        return;
    }
    inRefresh = YES;
    [prog setHidden:NO];
	[prog startAnimation:self];
    [table setEnabled:NO];
	NSDictionary* params = timer.userInfo;
	[((id<TaskList>)reporter) markComplete:params completeHandler:self selector:@selector(handleComplete:)];
	[WriteHandler completeActivity:params atTime:[timer fireDate]];
}

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
//			//NSLog(@"got val = %@", val);
			val = [NSString stringWithFormat:@"%@ : %@",[Utility dueTimeStrFor:due], val];
		}
		theValue = val;
	} else {
		theValue = [NSNumber numberWithInt: 0];
	}
	if ([theValue isKindOfClass:[NSString class]] && due){
		NSTimeInterval intv = [due timeIntervalSinceNow];
		NSDictionary *attrs = [self attributesForInterval: intv];
	//	//NSLog(@"val = %@",(NSString*)[params objectForKey:TASK_NAME]);
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
	[cell setControlSize:NSMiniControlSize];

	[col1 setDataCell:cell];
	[cell release];
}


- (void) handleDouble: (id) sender;
{
	int row = [sender selectedRow];
	
	NSDictionary *ctx = [data objectAtIndex:row];	
	[reporter handleClick:ctx];
}

- (void) endRefresh {
    data = refreshHandler.data;
    [table reloadData];
    NSTableColumn *checkCol = [[table tableColumns] objectAtIndex:0];
    [[checkCol dataCell]setEditable:YES];
    [table setEnabled:YES];
    inRefresh = NO;
}
@end

@implementation SummaryMailViewController

- (void) initTable{}

- (void) handleDouble: (id) sender;
{
	int row = [sender selectedRow];
    NSOutlineView *ov = (NSOutlineView*)table;
	
	NSDictionary *ctx = [ov itemAtRow:row];	
	[reporter handleClick:ctx];
}



- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil){
        return [data objectAtIndex:index];
    }
    NSAssert([item isKindOfClass: [NSDictionary class]], @"item not dictionary");
    NSDictionary* dataItem = item;
    NSArray *thread = [dataItem objectForKey:@"THREAD"];
    
    return (thread == nil) ? nil : [thread objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item == nil){
        return YES;
    }
    NSAssert([item isKindOfClass: [NSDictionary class]], @"item not dictionary");
    NSDictionary* dataItem = item;
    NSArray *thread = [dataItem objectForKey:@"THREAD"];
    return (thread != nil);
    
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil){
        return [data count];
    }
    NSAssert([item isKindOfClass: [NSDictionary class]], @"item not dictionary");
    NSDictionary* dataItem = item;
    NSArray *thread = [dataItem objectForKey:@"THREAD"];
    
    return (thread == nil) ? 0 : [thread count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id theValue;
    NSAssert([item isKindOfClass: [NSDictionary class]], @"item not dictionary");
    NSDictionary* params = item;
 
        NSColor *color = [params objectForKey:MAIL_COLOR];
    	NSString *colName = [tableColumn identifier];
    	if ([colName isEqualToString:@"COL1"])
    	{
    		theValue = [params objectForKey:MAIL_EMAIL];
    	}
    	else if  ([colName isEqualToString:@"COL2"]){
    		NSDate *due = (NSDate*) [params objectForKey:MAIL_ARRIVAL_TIME];
    		theValue = [Utility dueTimeStrFor:due];
    	} else {
    		theValue = [params objectForKey:MAIL_SUBJECT];
    	}
    	if (color){
    		theValue = [[NSAttributedString alloc]initWithString:theValue 
                                                      attributes:[self attributesForColor:color]];
    	}
        return theValue;
}
@end

