//
//  ActivitiesViewController.h
//  WorkPlayAway
//
//  Created by Charles on 7/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RefreshableViewController.h"
#import <SM2DGraphView/SMPieChartView.h>
#import "PieData.h"
#import "ActivityChart.h"

@interface ActivitiesViewController : RefreshableViewController {
	SMPieChartView *pieChart;
	PieData *pieData;
	NSProgressIndicator *busyInd;
	ActivityChart *activityChart;
    NSTableView *actTable;
	NSTextField *actTitle;
}
@property (nonatomic,retain) IBOutlet SMPieChartView *pieChart;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *busyInd;
@property (nonatomic, retain) PieData *pieData;
@property (nonatomic,retain) IBOutlet NSTextField *actTitle;
@property (nonatomic, retain) ActivityChart *activityChart;
@property (nonatomic,retain) IBOutlet NSTableView *actTable;

@end
