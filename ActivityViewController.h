//
//  ActivityViewController.h
//  WorkPlayAway
//
//  Created by Charles on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SM2DGraphView.h>
#import <SM2DGraphView/SMPieChartView.h>
#import "ActivityChart.h"

@interface ActivityViewController : NSViewController {
@private
    SMPieChartView *pieChart;
    NSTableView *table;
    NSProgressIndicator *busyInd;
    ActivityChart *activityChart;
}
@property (nonatomic,retain) IBOutlet SMPieChartView *pieChart;
@property (nonatomic, retain) IBOutlet NSTableView *table;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *busyInd;
@property (nonatomic, retain) IBOutlet ActivityChart *activityChart;
@end
