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
#import "SummaryStatusViewController.h"
#import "ColorWellCell.h"
#import "Utility.h"

@implementation StatsWindow
@synthesize resetButton;
@synthesize summaryTable;
@synthesize workTable;
//@synthesize playText;
//@synthesize workText;
//@synthesize awayText;

@synthesize pieChart;
@synthesize barChart;
@synthesize pieData;
@synthesize genButton;
@synthesize tabView;
@synthesize busyInd;
@synthesize goalsItem;
@synthesize goalChart;
@synthesize activityChart;
@synthesize activityItem;
@synthesize summaryItem;
@synthesize wh;
@synthesize actTable;
@synthesize actTitle;


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
//	NSArray *tabItems = tabView.tabViewItems;
//	[tabView removeTabViewItem:(NSTabViewItem*)[tabItems objectAtIndex:3]];
//	[tabView removeTabViewItem:(NSTabViewItem*)[tabItems objectAtIndex:2]];
    //SummaryStatusViewController *ssvc = [[SummaryStatusViewController alloc]initWithNibName:@"//SummaryStatusViewController" bundle:nil];
  //  [summaryItem setView:ssvc.view];
}
-(void) showWindow:(id)sender
{
	[super showWindow:sender];
	[self setContents];
}

-(void) windowDidLoad
{
    [[super window] setFrameAutosaveName:@"History"];
	[self setContents];
    SummaryStatusViewController *ssvc = [[SummaryStatusViewController alloc]initWithNibName:@"SummaryStatusViewController" bundle:nil]; 
    [summaryItem setView:ssvc.view];
}

- (void) setContents
{

	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	[busyInd setHidden:YES];
	[summaryTable noteNumberOfRowsChanged];
	[workTable noteNumberOfRowsChanged];

	goalChart = [[GoalChart alloc]init];
	goalChart.chart = barChart;
	goalChart.busy = busyInd;
	barChart.delegate = goalChart;
	barChart.dataSource = goalChart;
	[ barChart setAxisInset:[ SM2DGraphView barWidth ] forAxis:kSM2DGraph_Axis_X ];
	[ barChart setLiveRefresh:YES ];
	[ barChart refreshDisplay:self ];
//	[barChart reloadData];
    activityChart = [[ActivityChart alloc]init];
    activityChart.chart = pieChart;
    [pieChart setDelegate:activityChart];
    [pieChart setDataSource:activityChart];
    activityChart.busy =busyInd;
    activityChart.title = actTitle;
    [activityChart runQueryStarting:[NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)] 
						 ending:[NSDate date] 
					withContext:nad.managedObjectContext];
    [pieChart reloadData];
    [pieChart refreshDisplay:self];
    NSTableColumn *col = [[actTable tableColumns] objectAtIndex:0];
    [col setDataCell:[ColorWellCell new]];
    [actTable setDataSource:activityChart];
}

- (void) clickGen2: (id) sender
{
    if (!wh){
        wh = ((WPADelegate*)[NSApplication sharedApplication].delegate).ioHandler;
    }
	double work;
	double free;
	double rand1;
	double rand2;   
	for (int i = 0; i < 14; i++){
		NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(24.0 * 60.0 * 60.0) * -i];
		double r1 = rand();
		double r2 = rand();
		rand1 = fmod(r1, 2.0 * 60.0 * 60.0);
		rand2 = fmod(r2, 2.0 * 60.0 * 60.0);
		work = rand1 + 4.0 * 60.0 * 60.0;
		free = rand2 + 2.0 * 60.0 * 60.0;        
		[wh saveActivityForDate:date desc:@"foo" source:nil project:nil addVal:free];
        [wh saveActivityForDate:date desc:@"goo" source:@"source1" project:nil addVal:work];
        [wh saveActivityForDate:date desc:@"hoo" source:nil project:@"project1" addVal:free+work/2];
        [wh saveActivityForDate:date desc:@"joo" source:@"source1" project:@"project1" addVal:free+(work*1.5)];
        [wh saveActivityForDate:date desc:@"koo" source:@"source2" project:@"project2" addVal:(free * 1.5)+(work)];
    }
    [wh saveAction:self];
    NSAlert *alert = [NSAlert alertWithMessageText:@"Yay!" 
                                     defaultButton:nil alternateButton:nil 
                                       otherButton:nil 
                         informativeTextWithFormat:@"All Done!"];
    [alert runModal];	

}

- (void) clickGen: (id) sender
{
    if (!wh){
        wh = ((WPADelegate*)[NSApplication sharedApplication].delegate).ioHandler;
    }
	NSManagedObjectContext *moc = wh.managedObjectContext;
	//	((WPADelegate*)[NSApplication sharedApplication].delegate).managedObjectContext;
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
    [wh saveAction:self];

}
- (void) clickGen0: (id) sender
{
    if (!wh){
        wh = ((WPADelegate*)[NSApplication sharedApplication].delegate).ioHandler;
    }
	NSManagedObjectContext *moc = wh.managedObjectContext;
	//	((WPADelegate*)[NSApplication sharedApplication].delegate).managedObjectContext;
    
    
    NSManagedObject *newRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"AllTimeData"
                                   inManagedObjectContext:moc];
    
    NSDate *start = [NSDate dateWithTimeIntervalSinceNow:-24 * 14 * 60 * 60];
    [newRecord setValue:start forKey:@"dateStart"];
    [newRecord setValue:start forKey:@"dateWrite"];
    
    
    [newRecord setValue:[NSNumber numberWithInt:14] forKey:@"daysTotal"];		
    [newRecord setValue:[NSNumber numberWithInt:10] forKey:@"daysWorked"];		
    [newRecord setValue:[NSNumber numberWithInt:9] forKey:@"daysGoalAchieved"];		
    [newRecord setValue:[NSNumber numberWithDouble:24*14*60*60] forKey:@"timeTotal"];		
    [newRecord setValue:[NSNumber numberWithDouble:4*10*60*60] forKey:@"timeGoal"];		
    [newRecord setValue:[NSNumber numberWithDouble:4*10*60*60 - 68] forKey:@"timeWorked"];		
    [newRecord setValue:[NSDate distantPast] forKey:@"lastGoalAchieved"];		
    [newRecord setValue:[NSDate distantPast] forKey:@"lastWorked"];		
    [newRecord setValue:[NSDate distantPast] forKey:@"lastDay"];		
    
	
    NSError *err =nil;
    [newRecord validateForInsert:&err];
    if (err){
        [NSApp presentError:err];
        return;
    }
    [moc save:&err];
    [wh saveAction:self];
	
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSLog(@"didselect");
	if (tabViewItem == goalsItem){
		WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
		[busyInd startAnimation:self];
        [barChart setDataSource:goalChart];
		[goalChart runQueryStarting:[NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)] 
								 ending:[NSDate date] 
							withContext:nad.managedObjectContext];
        [barChart reloadData];
        [barChart reloadAttributes];
		
	}
   else {
		WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
		[busyInd startAnimation:self];
		[activityChart runQueryStarting:[NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)] 
                             ending:[NSDate date] 
                        withContext:nad.managedObjectContext];
       [pieChart reloadData];
       [pieChart reloadAttributes];
		
	}
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSLog(@"shouldselect");
	return YES;
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSLog(@"willSelect");
}
@end
