//
//  ActivityChart.m
//  WorkPlayAway
//
//  Created by Charles on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityChart.h"
#import "WriteHandler.h"
#import "WPADelegate.h"
#import "Utility.h"

@interface SliceData : NSObject {
@private
    NSNumber *total;
    NSMutableDictionary *keys;
}
@property (nonatomic, retain) NSNumber *total;
@property (nonatomic, retain) NSMutableDictionary *keys;

@end

@implementation SliceData
@synthesize total, keys;
- (id) init
{
    if (self){
        keys = [NSMutableDictionary new];
    }
    return self;
}
@end

@implementation ActivityChart
@synthesize chart;
@synthesize busy;
@synthesize seriesData;
@synthesize total;
@synthesize title;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib
{
    NSLog(@"activity chart awakeFromNib");
	chart.dataSource = self;
	chart.delegate = self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) runQueryStarting: (NSDate*) start ending: (NSDate*) end withContext: (NSManagedObjectContext *) moc
{
    
	[busy setHidden:NO];
	[busy startAnimation:self];
    WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication]delegate];
    [del.ioHandler performSelector:@selector(doFlush) onThread:del.ioThread withObject:nil waitUntilDone:YES];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"DailyActivity"
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
	NSPredicate *predicate =
    //   [NSPredicate predicateWithFormat:@"date >= %@ && date <= %@", start,end];
    [NSPredicate predicateWithFormat:@"date >= %@", start,end];
	[request setPredicate:predicate];
    NSMutableDictionary *allSlices = [NSMutableDictionary dictionaryWithCapacity:3];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
    total = 0.0;
	for (NSManagedObject *rec in array){
		SliceData *slice = [SliceData new];
		slice.total = (NSNumber*)[rec valueForKey:@"total"];
        total += [slice.total doubleValue];
        
        NSManagedObject *task = [rec valueForKey: @"task"];
        [slice.keys setValue:[task valueForKey: @"name"] forKey:@"task"];
        
        NSManagedObject *proj = [task valueForKey:@"project"];
        NSManagedObject *src  = [task valueForKey:@"source"];
        if (proj)
            [slice.keys setValue:[proj valueForKey:@"name"] forKey:@"project"];
        if (src)
            [slice.keys setValue:[src valueForKey:@"name"] forKey:@"source"];
        
        SliceData *data = [allSlices objectForKey:slice.keys];
        if (data){
            int newTotal = data.total.intValue + slice.total.intValue;
            data.total = [NSNumber numberWithInteger:newTotal];
        } else {
            [allSlices setObject:slice forKey:slice.keys];
        }
    
	}
    NSString *totalStr = [Utility formatInterval:total];
   [title setStringValue:[NSString stringWithFormat:@"Total: Work %@",totalStr]];

	seriesData = [NSMutableArray arrayWithArray:[allSlices allValues]];

	//sort the data
	NSSortDescriptor *goalSort = [[NSSortDescriptor alloc] initWithKey:@"total"
															 ascending:NO
															  selector:@selector(compare:)];
	NSArray *descArray = [[NSArray alloc] initWithObjects:goalSort,nil];
	[seriesData sortUsingDescriptors:descArray];
	[busy stopAnimation:self];
	[busy setHidden:YES];
}

- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView
{
    NSLog(@"%u slices", [seriesData count]);
    return [seriesData count];
}

- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex
{    
    SliceData *data = (SliceData*)[seriesData objectAtIndex: inSliceIndex ];
    NSLog(@"slice %d value: %f",inSliceIndex, data.total.doubleValue);
    return data.total.doubleValue;
}

- (NSArray *)pieChartViewArrayOfSliceData:(SMPieChartView *)inPieChartView
{
    NSArray     *result = nil;
	
    
    return result;
}

- (CGFloat) calcHueForRatio: (CGFloat) ratio
{
    /** at zero we should be red (90) and at 100 we should be at orange (60) **/
    CGFloat start = 0.0;
    CGFloat end = 240.0;
    CGFloat range = end - start;
    CGFloat dist = ratio * range;
    return dist / 360.0;
}


- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex
{
    NSDictionary    *result = nil;
    NSColor         *tempColor = nil;
    
    CGFloat ratio = ((CGFloat)inSliceIndex / [seriesData count]);
    
    CGFloat hue = [self calcHueForRatio: ratio];
    tempColor = [NSColor colorWithDeviceHue:hue saturation:0.66 brightness:0.80 alpha:1];
	
    // Make it transparent.
//    tempColor = [ tempColor colorWithAlphaComponent:0.4 ];
    
    result = [ NSDictionary dictionaryWithObject:tempColor forKey:NSBackgroundColorAttributeName ];
	NSLog(@"returning: %@",result);
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
 //   int slice = [inPieChartView convertToSliceFromPoint:inPoint fromView:inPieChartView];
    
}

- (NSString *)pieChartView:(SMPieChartView *)inPieChartView labelForSliceIndex:(unsigned int)inSliceIndex
{ 
    SliceData *data = (SliceData*)[seriesData objectAtIndex: inSliceIndex ];
    NSLog(@"slice %d name: %@",inSliceIndex,[data.keys objectForKey:@"task"]);
    return [data.keys objectForKey:@"task"];
    
}

- (void)pieChartViewCompletedDrawing:(SMPieChartView *)inPieChartView
{
    // This is just an example of what you could do...
	//    if ( inPieChartView == _sm_hardDrive )
	//        NSLog( @"We're done drawing the hard drive usage chart." );
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSInteger ret = [seriesData count];
    NSLog(@"rows = %d", ret);
    
	return ret;
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
	NSParameterAssert(seriesData != nil);
	NSParameterAssert(row >= 0 && row < [seriesData count]);
	
	NSString *colName = [tableColumn identifier];
    
	if ([colName isEqualToString:@"SWATCH"]){
        CGFloat ratio = ((CGFloat)row / [seriesData count]);
        CGFloat hue = [self calcHueForRatio: ratio];
        theValue = [NSColor colorWithDeviceHue:hue saturation:0.66 brightness:0.80 alpha:1];

	} else if ([colName isEqualToString:@"INFO"]){
        SliceData *data = (SliceData*)[seriesData objectAtIndex: row ];
        NSLog(@"slice %d name: %@",row,[data.keys objectForKey:@"task"]);
        NSString *task = [data.keys objectForKey:@"task"];
        NSTimeInterval totalInt = [data.total doubleValue];
        NSString *timeStr = [Utility formatInterval:totalInt];
        theValue = [NSString stringWithFormat:@"%@ %@",timeStr,task];	
    }
    NSLog(@"returning %@", theValue);
    return theValue;
}



@end
