//
//  GoalChart.m
//  Self-Imposed Structure
//
//  Created by Charles on 2/7/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//
#import "Utility.h"
#import "GoalChart.h"
#import "WPADelegate.h"

@interface GoalRecord : NSObject
{
	double work;
	double goal;
	NSDate *date;
}
- (double) ptValForIdx:(unsigned int)inLineIndex;
@property (nonatomic) double  work;
@property (nonatomic) double  goal;
@property (nonatomic, retain) NSDate *date;
@end
@implementation GoalRecord
@synthesize work;
@synthesize goal;
@synthesize date;
- (double) ptValForIdx:(unsigned int)inLineIndex
{
	return inLineIndex == 0 ? work : goal;
}
@end


@implementation GoalChart
@synthesize seriesData;
@synthesize chart;
@synthesize maxAxis;
@synthesize minAxis;
@synthesize busy;

-(void) awakeFromNib
{
	chart.dataSource = self;
	chart.delegate = self;
	[ chart setAxisInset:[ SM2DGraphView barWidth ] forAxis:kSM2DGraph_Axis_X ];
	//	[ chart setDrawsLineAtZero:YES forAxis:kSM2DGraph_Axis_Y ];
	[ chart setLiveRefresh:YES ];
	[ chart refreshDisplay:self ];
	[ chart setNumberOfTickMarks:3 forAxis:kSM2DGraph_Axis_X];
	[chart setDelegate:self];
	BOOL labelForTickMark = [ self respondsToSelector:@selector(twoDGraphView:labelForTickMarkIndex:forAxis:defaultLabel:) ];
	
	BOOL willDisplayBarIndex = [ self respondsToSelector:@selector(twoDGraphView:willDisplayBarIndex:forLineIndex:withAttributes:) ];
	
	BOOL wantsMouseDowns = [ self respondsToSelector:@selector(twoDGraphView:didClickPoint:) ];
	
	BOOL wantsEndDraw = [ self respondsToSelector:@selector(twoDGraphView:doneDrawingLineIndex:) ];
	//NSLog(@"awakeFromNib labelForTickMark = %d, willDisplayBarIndex = %d wantMouseDowns = %d wantsEndDraw = %d",
	//	  labelForTickMark, willDisplayBarIndex,wantsMouseDowns, wantsEndDraw);
}

- (void) runQueryStarting: (NSDate*) start ending: (NSDate*) end withContext: (NSManagedObjectContext *) moc
{
	[busy setHidden:NO];
	[busy startAnimation:self];
    WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication]delegate];
    [del.ioHandler performSelector:@selector(doFlush) onThread:del.ioThread withObject:nil waitUntilDone:YES];	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"DailySummary"
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
	NSPredicate *predicate =
	  [NSPredicate predicateWithFormat:@"recordDate >= %@ && recordDate <= %@", start,end];
	[request setPredicate:predicate];
	double minVal = DBL_MAX;
	double maxVal = 0;
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	seriesData = [[NSMutableArray alloc]initWithCapacity:[array count]];
	for (NSManagedObject *rec in array){
		GoalRecord *gRec = [GoalRecord new];
		NSNumber *actNum = (NSNumber*)[rec valueForKey:@"timeWork"];
		NSNumber *goalNum = (NSNumber*)[rec valueForKey:@"timeGoal"];
		gRec.work = [actNum doubleValue]/3600.0;
		gRec.goal = [goalNum doubleValue]/3600.0;
		maxVal = (gRec.work > maxVal)  ?gRec.work : maxVal;
		maxVal = (gRec.goal> maxVal) ?gRec.goal : maxVal;
		minVal = (gRec.work < minVal) ? gRec.work : minVal;
		minVal = (gRec.goal < minVal) ?gRec.goal : minVal;
		gRec.date = [(NSDate*) [rec valueForKey:@"recordDate"] copy];

		[seriesData addObject:gRec];
	}
	//sort the data
	NSSortDescriptor *goalSort = [[NSSortDescriptor alloc] initWithKey:@"date"
															 ascending:YES
															  selector:@selector(compare:)];
	NSArray *descArray = [[NSArray alloc] initWithObjects:goalSort,nil];
	[seriesData sortUsingDescriptors:descArray];
	maxAxis = ceil(maxVal) ;
	minAxis = floor(minVal);
	int yTicks = ((maxAxis - minAxis) * 2) + 1;
	[ chart setNumberOfTickMarks:[seriesData count] forAxis:kSM2DGraph_Axis_X];
	[ chart setNumberOfTickMarks:yTicks forAxis:kSM2DGraph_Axis_Y];
	[busy stopAnimation:self];
	[busy setHidden:YES];
}


#pragma mark -
#pragma mark • SM2DGRAPHVIEW DATASOURCE METHODS

- (NSUInteger)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView
{
	return 2;
}


- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView dataForLineIndex:(NSUInteger)inLineIndex
{
    NSMutableArray	*result = [[NSMutableArray alloc]initWithCapacity:[seriesData count]];
	int ptIdx = 1;
	for(GoalRecord *gRec in seriesData){
		[ result addObject:NSStringFromPoint( NSMakePoint( ptIdx++ * 1.0,[gRec ptValForIdx:inLineIndex] ) ) ];
	}
    return (NSArray*)result;
}

- (NSData *)twoDGraphView:(SM2DGraphView *)inGraphView dataObjectForLineIndex:(NSUInteger)inLineIndex
{
    NSData	*result = nil;
	
    return result;
}

- (CGFloat)twoDGraphView:(SM2DGraphView *)inGraphView maximumValueForLineIndex:(NSUInteger)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis
{
	double ret;
	if ( inAxis == kSM2DGraph_Axis_X )
		ret = ([seriesData count ]) * 1.0;
	else
		ret = maxAxis;
	return ret;
}

- (CGFloat)twoDGraphView:(SM2DGraphView *)inGraphView minimumValueForLineIndex:(NSUInteger)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis
{	
	double ret;
	if ( inAxis == kSM2DGraph_Axis_X )
		ret = 1.0;
	else
		ret = minAxis;
	return ret;
}

- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView attributesForLineIndex:(NSUInteger)inLineIndex
{
    NSDictionary	*result = nil;
	
	
	// Make this a bar graph.
	// We could make it blue here if every bar was blue.
    NSColor *blueColor = [NSColor colorWithDeviceHue:0.66 saturation:1.0 brightness:.80 alpha:1.0];
    NSColor *redColor = [NSColor colorWithDeviceHue:0.0 saturation:1.0 brightness:.80 alpha:1.0];
	result = inLineIndex == 0 ? [ NSDictionary dictionaryWithObjectsAndKeys:
								 [ NSNumber numberWithBool:YES ], SM2DGraphBarStyleAttributeName,
								                    blueColor, NSBackgroundColorAttributeName,
								 nil ]: [ NSDictionary dictionaryWithObjectsAndKeys:
										 redColor, NSForegroundColorAttributeName,
										 [ NSNumber numberWithBool:YES ], SM2DGraphDontAntialiasAttributeName,
										 [ NSNumber numberWithInt:kSM2DGraph_Dash_None ], SM2DGraphLineDashAttributeName,
										 nil ];
	
  	
    return result;
}

// show three ticks max
- (BOOL) showTickForIndex:(unsigned int) idx
{
    int count = [seriesData count];
    unsigned int middle = (int)(floor((float)[seriesData count] / 2.0) - 1.0);
    if (count < 9)
        return idx == 0 || idx == ([seriesData count]-1);
    else {
        BOOL ret;
        if (idx == 0)
            ret = YES;
        else if (idx == middle)
            ret = YES;
        else if (idx == ([seriesData count] - 1))
            ret = YES;
        else
            ret = NO;
        //NSLog(@"ret = %d for idx = %d", ret, idx);
        return ret;
    }
    
}
#pragma mark -
#pragma mark • SM2DGRAPHVIEW DELEGATE METHODS

- (NSString *)twoDGraphView:(SM2DGraphView *)inGraphView 
	  labelForTickMarkIndex:(NSUInteger)inTickMarkIndex
					forAxis:(SM2DGraphAxisEnum)inAxis 
			   defaultLabel:(NSString *)inDefault
{
    NSString	*result = inDefault;
	
	if (inAxis == kSM2DGraph_Axis_X){
		GoalRecord *gRec = (GoalRecord*) [seriesData objectAtIndex:inTickMarkIndex];
        result = [self showTickForIndex:inTickMarkIndex] ? [Utility MdStrFor:gRec.date] : nil;
        if (result) NSLog(@"tick %@ on idx = %d", [self showTickForIndex:inTickMarkIndex] ? @"YES" : @"NO",inTickMarkIndex);
	}
	else {
		result = [NSString stringWithFormat:@"%@ hr",inDefault];
	}
    return result;
}

- (void)twoDGraphView:(SM2DGraphView *)inGraphView 
  willDisplayBarIndex:(NSUInteger)inBarIndex 
		 forLineIndex:(NSUInteger)inLineIndex 
	   withAttributes:(NSMutableDictionary *)attr
{
    if ( inGraphView == chart )
    {
        if ( 1 == inLineIndex )
            // Make the second (zero based index of 1) bar orange.
            [ attr setObject:[ [ NSColor orangeColor ] blendedColorWithFraction:0.7 ofColor:[ NSColor blackColor ] ]
					  forKey:NSForegroundColorAttributeName ];
        else
            // Make the rest of the bars blue.
            [ attr setObject:[ NSColor blueColor ] forKey:NSForegroundColorAttributeName ];
    }
}

- (void)twoDGraphView:(SM2DGraphView *)inGraphView didClickPoint:(NSPoint)inPoint
{
	
}

- (void)twoDGraphView:(SM2DGraphView *)inGraphView doneDrawingLineIndex:(NSUInteger)inLineIndex
{
    // This is just an example of what you could do...
	//    if ( inGraphView == _sm_trigGraph )
	//NSLog( @"We're done drawing line number %d.", inLineIndex );
}

@end

