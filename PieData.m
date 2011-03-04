//
//  PieData.m
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "PieData.h"


@implementation PieData
- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView
{
    unsigned int    result = 0;

        result = 5;
   
    return result;
}

- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex
{
    double      result = 0.0;

        switch ( inSliceIndex )
        {
			case 0: result = 2.0;   break;
			case 1: result = 3.0;   break;
			case 2: result = 4.0;   break;
			case 3: result = 5.0;   break;
			case 4: result = 7.0;   break;
        }
    
	
    return result;
}

- (NSArray *)pieChartViewArrayOfSliceData:(SMPieChartView *)inPieChartView
{
    NSArray     *result = nil;
	

    return result;
}

- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex
{
    NSDictionary    *result = nil;
    NSColor         *tempColor = nil;
	
    switch ( inSliceIndex % 7 )
    {
		default:
		case 0:		tempColor = [ NSColor blackColor ];		break;
		case 1:		tempColor = [ NSColor redColor ];		break;
		case 2:		tempColor = [ NSColor greenColor ];		break;
		case 3:		tempColor = [ NSColor blueColor ];		break;
		case 4:		tempColor = [ NSColor yellowColor ];	break;
		case 5:		tempColor = [ NSColor cyanColor ];		break;
		case 6:		tempColor = [ NSColor magentaColor ];	break;
    }
	
        // Make it transparent.
        tempColor = [ tempColor colorWithAlphaComponent:0.4 ];

        result = [ NSDictionary dictionaryWithObject:tempColor forKey:NSBackgroundColorAttributeName ];
	
    return result;
}

- (unsigned int)numberOfExplodedPartsInPieChartView:(SMPieChartView *)inPieChartView
{
    unsigned int    result = 0;
	
    return result;
}

- (NSRange)pieChartView:(SMPieChartView *)inPieChartView rangeOfExplodedPartIndex:(unsigned int)inIndex
{
    NSRange     result = { 0, 0 };

	
    return result;
}

#pragma mark -
#pragma mark • SMPIECHARTVIEW DELEGATE METHODS

- (void)pieChartView:(SMPieChartView *)inPieChartView didClickPoint:(NSPoint)inPoint
{

}

- (NSString *)pieChartView:(SMPieChartView *)inPieChartView labelForSliceIndex:(unsigned int)inSliceIndex
{ return @"";
}

- (void)pieChartViewCompletedDrawing:(SMPieChartView *)inPieChartView
{
    // This is just an example of what you could do...
	//    if ( inPieChartView == _sm_hardDrive )
	//        NSLog( @"We're done drawing the hard drive usage chart." );
}


@end
