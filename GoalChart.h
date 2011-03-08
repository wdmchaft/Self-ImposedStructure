//
//  GoalChart.h
//  WorkPlayAway
//
//  Created by Charles on 2/7/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SM2DGraphView.h>
#import <SM2DGraphView/SMPieChartView.h>

@interface GoalChart : NSObject {
	SM2DGraphView *chart;
	NSMutableArray *seriesData;
	double maxAxis;
	double minAxis;
	NSProgressIndicator *busy;
}

@property (nonatomic,retain) IBOutlet SM2DGraphView *chart;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *busy;
@property (nonatomic,retain)  NSMutableArray *seriesData;
@property (nonatomic)  double maxAxis;
@property (nonatomic)  double minAxis;
- (void) runQueryStarting: (NSDate*) start ending: (NSDate*) end withContext: (NSManagedObjectContext *) moc;

@end

