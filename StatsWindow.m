//
//  StatsWindow.m
//  Nudge
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "StatsWindow.h"
#import "WPADelegate.h"
#import "Schema.h"
#import "math.h"
#import "GoalChart.h"

@implementation StatsWindow
@synthesize resetButton;
@synthesize summaryTable;
@synthesize workTable;
//@synthesize playText;
//@synthesize workText;
//@synthesize awayText;
@synthesize statsData;
@synthesize workData;
@synthesize statsArray;
@synthesize workArray;
@synthesize pieChart;
@synthesize barChart;
@synthesize pieData;
@synthesize genButton;
@synthesize tabView;

- (void) clickClear: (id) sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" 
									 defaultButton:@"No" alternateButton:@"Yes" 
									   otherButton:nil 
						 informativeTextWithFormat:@"Do you want to delete all stored tracking data?\n%@ needs to quit to complete this action.  Click 'Yes' to continue.",__APPNAME__];
	[alert runModal];
	NSButton *yes = (NSButton*)[alert.buttons objectAtIndex:1];
	if (yes.state == NSOnState) {
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] removeStore: self];
		[super.window close];
	}
}

//-(void) windowDidLoad
//{
//
//}
-(id) initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
	if (self)
	{
		NSLog(@"in init");
	//	[self setContents];
		// hide two tabs we don't care about
		
	}
	return self;
}
- (void) awakeFromNib
{
	NSArray *tabItems = tabView.tabViewItems;
	[tabView removeTabViewItem:(NSTabViewItem*)[tabItems objectAtIndex:3]];
	[tabView removeTabViewItem:(NSTabViewItem*)[tabItems objectAtIndex:2]];
}
-(void) showWindow:(id)sender
{
	
	[self setContents];
}

-(void) windowDidLoad
{
	[self setContents];
}

- (void) setContents
{

	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	[nad newRecord:[Context sharedContext].currentState];

	statsArray = [Schema statsReportForDate:[NSDate date] inContext:nad.managedObjectContext];
	statsData = [[SummaryTable alloc]initWithRows: statsArray];
	summaryTable.dataSource = statsData;
	[summaryTable noteNumberOfRowsChanged];
	workArray = [Schema fetchWorkReportForMonth:[NSDate date] inContext:nad.managedObjectContext];
	workData = [[WorkTable alloc]initWithRows: workArray];
	workTable.dataSource = workData;
	[workTable noteNumberOfRowsChanged];
	pieData = [PieData new];
	pieChart.dataSource = pieData;
	[pieChart reloadData];
	GoalChart *goalChart = [[GoalChart alloc]init];
	goalChart.chart = barChart;
	barChart.delegate = goalChart;
	[goalChart runQueryStarting:[NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)] 
						 ending:[NSDate date] 
					withContext:nad.managedObjectContext];
	barChart.dataSource = goalChart;
	[ barChart setAxisInset:[ SM2DGraphView barWidth ] forAxis:kSM2DGraph_Axis_X ];
	//	[ chart setDrawsLineAtZero:YES forAxis:kSM2DGraph_Axis_Y ];
	[ barChart setLiveRefresh:YES ];
	[ barChart refreshDisplay:self ];
	[barChart reloadData];
}

- (void) clickGen: (id) sender
{
	NSManagedObjectContext *moc = 
		((WPADelegate*)[NSApplication sharedApplication].delegate).managedObjectContext;
	double goal = 18000.0;
	double work;
	double free;
	double rand1;
	double rand2;
	srand(time(nil));
	NSError *err = nil;
	for (int i = 0; i < 14 && err == nil; i++){
		NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(24.0 * 60.0 * 60.0) * -i];

		NSManagedObject *newRecord = [NSEntityDescription
										insertNewObjectForEntityForName:@"DailySummary"
										inManagedObjectContext:moc];
		double r1 = rand();
		double r2 = rand();
		rand1 = fmod(r1, 2.0 * 60.0 * 60.0);
		rand2 = fmod(r2, 2.0 * 60.0 * 60.0);
		work = rand1 + 4.0 * 60.0 * 60.0;
		free = rand2 + 2.0 * 60.0 * 60.0;	
		NSLog(@"goal %f work %f free %f", goal,work,free);
		BOOL passed = work > goal;
		[newRecord setValue:[NSNumber numberWithDouble:work] forKey:@"timeWork"];
		[newRecord setValue:[NSNumber numberWithDouble:goal] forKey:@"timeGoal"];
		[newRecord setValue:[NSNumber numberWithDouble:free] forKey:@"timeFree"];
		[newRecord setValue:date forKey:@"recordDate"];
		[newRecord setValue:[NSNumber numberWithInt:passed] forKey:@"passedGoal"];
		[moc save:&err];
		
		
	}
	if (err){
		[[NSApplication sharedApplication] presentError:err];
	}
}

@end
