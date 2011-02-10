//
//  StatsWindow.h
//  Nudge
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SMPieChartView.h>
#import <SM2DGraphView/SM2DGraphView.h>
#import "SummaryTable.h"
#import "WorkTable.h"
#import "PieData.h"
#import "GraphData2.h"

@interface StatsWindow : NSWindowController {
	NSButton *resetButton;
	NSTabView *tabView;
	NSTableView *summaryTable;
	NSTableView *workTable;
	NSArray* statsArray;
	NSArray* workArray;
	SummaryTable *statsData;
	WorkTable *workData;
	NSTabView *tabs;
	SMPieChartView *pieChart;
	SM2DGraphView *barChart;
	PieData *pieData;
	GraphData2 *graphData;
	NSButton *genButton;
}
@property (nonatomic,retain) IBOutlet NSButton *resetButton;
@property (nonatomic,retain) IBOutlet NSTableView *summaryTable;
@property (nonatomic,retain) IBOutlet NSTableView *workTable;
@property (nonatomic,retain) IBOutlet SMPieChartView *pieChart;
@property (nonatomic,retain) IBOutlet SM2DGraphView *barChart;
@property (nonatomic,retain) IBOutlet NSButton *genButton;
@property (nonatomic,retain) IBOutlet NSTabView *tabView;

@property (nonatomic,retain) NSArray *statsArray;
@property (nonatomic,retain) NSArray *workArray;
@property (nonatomic,retain) StatsTable *statsData;
@property (nonatomic,retain) WorkTable *workData;
@property (nonatomic, retain) PieData *pieData;
@property (nonatomic, retain) GraphData2 *graphData;
-(IBAction) clickClear: (id) sender;
-(IBAction) clickGen: (id) sender;
-(void) setContents;
@end
