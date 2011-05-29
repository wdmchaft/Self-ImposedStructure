//
//  StatsWindow.h
//  Self-Imposed Structure
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SMPieChartView.h>
#import <SM2DGraphView/SM2DGraphView.h>
#import "SummaryTable.h"
#import "WorkTable.h"
#import "PieData.h"
#import "GoalChart.h"
#import "ActivityChart.h"
#import "WriteHandler.h"
#import "TasksDataSource.h"

@interface StatsWindow : NSWindowController <NSTabViewDelegate> {
	NSButton *resetButton;
	NSTabView *tabView;
	NSTableView *summaryTable;
	NSTableView *workTable;
	NSArray* workArray;
	WorkTable *workData;
	NSTabView *tabs;
	SMPieChartView *pieChart;
	SM2DGraphView *barChart;
	PieData *pieData;
	NSButton *genButton;
	NSProgressIndicator *busyInd;
	NSTabViewItem *goalsItem;
	NSTabViewItem *activityItem;
	NSTabViewItem *summaryItem;
	GoalChart *goalChart;
	ActivityChart *activityChart;
    WriteHandler *wh;
    NSTableView *actTable;
    NSTextField *actTitle;
	NSTableView *tasksTable;
	TasksDataSource *tasksDataSource;
}
@property (nonatomic,retain) IBOutlet NSButton *resetButton;
@property (nonatomic,retain) IBOutlet NSTableView *summaryTable;
@property (nonatomic,retain) IBOutlet NSTableView *workTable;
@property (nonatomic,retain) IBOutlet SMPieChartView *pieChart;
@property (nonatomic,retain) IBOutlet SM2DGraphView *barChart;
@property (nonatomic,retain) IBOutlet NSButton *genButton;
@property (nonatomic,retain) IBOutlet NSTabView *tabView;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *busyInd;
@property (nonatomic,retain) IBOutlet NSTabViewItem *goalsItem;
@property (nonatomic,retain) IBOutlet NSTabViewItem *summaryItem;
@property (nonatomic,retain) IBOutlet NSTabViewItem *activityItem;
@property (nonatomic,retain) IBOutlet NSTableView *actTable;
@property (nonatomic,retain) IBOutlet NSTextField *actTitle;
@property (nonatomic,retain) IBOutlet NSTableView *tasksTable;
@property (nonatomic,retain) IBOutlet TasksDataSource *tasksDataSource;

@property (nonatomic,retain) NSArray *workArray;
@property (nonatomic,retain) WorkTable *workData;
@property (nonatomic, retain) PieData *pieData;
@property (nonatomic, retain) GoalChart *goalChart;
@property (nonatomic, retain) ActivityChart *activityChart;
@property (nonatomic, retain) WriteHandler *wh;
-(IBAction) clickClear: (id) sender;
-(IBAction) clickGen: (id) sender;
-(IBAction) clickGen0: (id) sender;
-(IBAction) clickGen2: (id) sender;
-(void) setContents;
@end
