//
//  PieData.h
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SM2DGraphView.h>
#import <SM2DGraphView/SMPieChartView.h>

@interface PieData : NSObject {
}
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
