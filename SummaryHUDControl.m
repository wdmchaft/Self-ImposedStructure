//
//  SummaryHudControl.m
//  WorkPlayAway
//
//  Created by Charles on 1/18/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SummaryHUDControl.h"
#import "WPADelegate.h"
#import "Context.h"
#import "TaskList.h"
#import "Instance.h"
#import "Reporter.h"

#import <BWToolkitFramework/BWToolkitFramework.h>
@implementation SummaryHUDControl
@synthesize finishedCount;
@synthesize doneCount;
@synthesize mailsData;
@synthesize eventsData;
@synthesize tasksData;
@synthesize deadlinesData;
@synthesize tasksTable;
@synthesize deadlinesTable;
@synthesize eventsTable;
@synthesize mailTable;
@synthesize mainControl;


- (void) processSummary
{
//	WPADelegate *del = (WPADelegate*)[NSApplication sharedApplication].delegate;
	Context	*ctx = [Context sharedContext];
	// tell all of the modules that *I* am their master until further notice
	// and tell them to start gathering summary data for me
	NSDictionary *modules = [ctx instancesMap];
	<Instance> module = nil;
	NSString *modName = nil;
	NSMutableArray *runMods = [NSMutableArray new];
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled && [(id)module conformsToProtocol:@protocol(Reporter) ] ){
			[runMods addObject:module];
		}
	}
	finishedCount = [runMods count];
	for (<Reporter> reporter in runMods){
		[reporter refresh:self];
	}
}

-(void) handleAlert:(Note*) alert 
{
	Context *ctx = [Context sharedContext];
	if (alert.lastAlert){
		doneCount++;
		
		NSLog(@"received done from %@",alert.moduleName);
		if (doneCount == finishedCount){
			[self allSummaryDataReceived];
		}
	}
	else {
		NSLog(@"received %@",alert.message);
		<Instance> modForAlert = [ctx.instancesMap objectForKey:alert.moduleName];
		NSDate *due = nil;
		switch (modForAlert.category) {
			case CATEGORY_EMAIL:
				
				[mailsData.data addObject:alert.params];
				break;
			case CATEGORY_TASKS:
				
				due = [alert.params objectForKey:@"due_time"];
				if (due){
					[deadlinesData.data addObject:alert.params];
				}
				else {
					[tasksData.data addObject:alert.params];
				}
				break;
			case CATEGORY_EVENTS:
				[eventsData.data addObject:alert.params];
				break;
			default:
				break;
		}
	}
	
}
-(void) handleError: (Note*) error{
	if (doneCount++ == finishedCount){
		[self allSummaryDataReceived];
	}
}

- (void) allSummaryDataReceived
{
	[self showWindow: nil];
	[tasksTable noteNumberOfRowsChanged];
	[eventsTable noteNumberOfRowsChanged];
	[deadlinesTable noteNumberOfRowsChanged];
	[mailTable noteNumberOfRowsChanged];
}

- (void) showWindow:(id)sender
{
	mainControl = sender; 
	[super.window makeKeyAndOrderFront:nil];
	[super.window orderFrontRegardless];
}

- (void) windowDidLoad
{
	NSLog(@"in windowDidLoad tasksData = %@", tasksData);
	tasksTable.dataSource = tasksData;
	eventsTable.dataSource = eventsData;
	deadlinesTable.dataSource = deadlinesData;
	mailTable.dataSource = mailsData;
	[super.window makeKeyAndOrderFront:nil];
	[super.window orderFrontRegardless];
}

-(void) initTaskTable: (NSTableView*) modulesTable
{
	NSArray *allCols = modulesTable.tableColumns;
	NSTableColumn *col1 = [allCols objectAtIndex:0];
	
    NSButtonCell *cell;
    cell = [[NSButtonCell alloc] init];
    [cell setButtonType:NSSwitchButton];
    [cell setTitle:@""];
    [cell setAction:@selector(toggleModule:)];
    [cell setTarget:self];
	
	[col1 setDataCell:cell];
	[cell release];
}

- (IBAction) checkTask: (id) sender
{
	int row = [sender selectedRow];
	SummaryData *sumData = ((NSTableView*)sender).dataSource;
	
	NSDictionary *params = [sumData.data objectAtIndex:row];
	NSString *modName = [params objectForKey:@"module"];
	Context *ctx = [Context sharedContext];
	id callMod = [ctx.instancesMap objectForKey:modName];
	
	if ([callMod conformsToProtocol:@protocol(TaskList)]) {
		[(<TaskList>)callMod markComplete:params];
		[sender noteNumberOfRowsChanged];
	}
}

-(void) awakeFromNib
{					
	mailsData = [SummaryMailData new];
	tasksData = [SummaryTaskData new];
	deadlinesData = [SummaryDeadlineData new];
	eventsData = [SummaryEventData new];
//	[self initTaskTable: deadlinesTable];
//	[self initTaskTable: tasksTable];
	[deadlinesTable setDoubleAction:@selector(handleDouble:)];
	[tasksTable setDoubleAction:@selector(handleDouble:)];
	[eventsTable setDoubleAction:@selector(handleDouble:)];
	[mailTable setDoubleAction:@selector(handleDouble:)];

}
- (void) handleDouble: (id) sender;
{
	int row = [sender selectedRow];
	SummaryData *sumData = ((NSTableView*)sender).dataSource;
	
	NSDictionary *ctx = [sumData.data objectAtIndex:row];
	<Module> callMod = [[Context sharedContext].instancesMap objectForKey:[ctx objectForKey: @"module"]];
	
	[callMod handleClick:ctx];
}

- (void) windowWillClose: (NSNotification *) event
{
	NSLog(@"windowWillClose");
	[mainControl changeState:[Context sharedContext].previousState];
}
@end
