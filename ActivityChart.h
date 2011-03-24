//
//  ActivityChart.h
//  WorkPlayAway
//
//  Created by Charles on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <SM2DGraphView/SMPieChartView.h>

@interface ActivityChart : NSObject {
    @private
    NSMutableArray *seriesData;
    SMPieChartView *chart;
    NSProgressIndicator *busy;

}
@property (nonatomic,retain) IBOutlet SMPieChartView *chart;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *busy;
@property (nonatomic, retain) NSMutableArray *seriesData;
- (void) runQueryStarting: (NSDate*) start ending: (NSDate*) end withContext: (NSManagedObjectContext *) moc;

- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView;
- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex;
- (NSArray *)pieChartViewArrayOfSliceData:(SMPieChartView *)inPieChartView;
- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex;
- (unsigned int)numberOfExplodedPartsInPieChartView:(SMPieChartView *)inPieChartView;

- (NSRange)pieChartView:(SMPieChartView *)inPieChartView rangeOfExplodedPartIndex:(unsigned int)inIndex;

#pragma mark -
#pragma mark • SMPIECHARTVIEW DELEGATE METHODS

- (void)pieChartView:(SMPieChartView *)inPieChartView didClickPoint:(NSPoint)inPoint;
- (NSString *)pieChartView:(SMPieChartView *)inPieChartView labelForSliceIndex:(unsigned int)inSliceIndex;
- (void)pieChartViewCompletedDrawing:(SMPieChartView *)inPieChartView;
@end
