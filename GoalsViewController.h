//
//  GoalsViewController.h
//  WorkPlayAway
//
//  Created by Charles on 7/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RefreshableViewController.h"
#import <SM2DGraphView/SM2DGraphView.h>
#import "GoalChart.h"

@interface GoalsViewController : RefreshableViewController {
	SM2DGraphView *barChart;
	GoalChart *goalChart;
	NSProgressIndicator *prog;
}
@property (nonatomic,retain) IBOutlet SM2DGraphView *barChart;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *prog;
@property (nonatomic, retain) GoalChart *goalChart;

@end
