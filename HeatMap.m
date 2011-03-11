//
//  HeatMap.m
//  WorkPlayAway
//
//  Created by Charles on 3/10/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "HeatMap.h"


@implementation HeatMap
@synthesize colors;
@synthesize windows;

- (id) init
{
	if (self){
		[self load];
	}
	return self;
}

- (void) save
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[colors count]];
	for (NSColor *color in colors){
		[temp addObject:[NSArchiver archivedDataWithRootObject:color]];
	}
	[ud setObject: temp forKey:COLORS];
	[ud setObject: colors forKey:WINDOWS];
}


+ (NSData*) archColorWithRed: (double) rd green: (double) gr blue: (double) bl
{
	NSColor *clr = [NSColor colorWithDeviceRed:rd green:gr blue:bl alpha:1.0];
	return [NSArchiver archivedDataWithRootObject:clr];
}
+ (NSData*) archColorWithHue: (double) hue saturation : (double) saturation brightness: (double) brightness
{
	NSColor *clr = [NSColor colorWithDeviceHue:hue saturation:saturation brightness:brightness alpha:1.0];
	return [NSArchiver archivedDataWithRootObject:clr];
}
+ (NSColor*) colorFromArch: (NSData*) data
{
	NSColor * aColor =nil;
	if (data != nil)
		aColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:data];
	return aColor;
}

- (void) load
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSArray *ary = [ud objectForKey:COLORS];
	NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:[ary count]];
	for (NSData *data in ary){
		[temp addObject:[HeatMap colorFromArch:data]];
	}
	colors = temp;
	windows = [ud objectForKey:WINDOWS];
}
/****
 #FA0000 30 min
 #FC6C00 2 hour
 #FFFF00 1 day
 #BFFB00 2 day
 #83EF6F 3 day
 #1FECFF more
 ****/
+ (void) initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSArray *defaultColors = [NSArray arrayWithObjects:
							  [HeatMap archColorWithHue:0.808 saturation:1.0 brightness:0.98],// purple
							  [HeatMap archColorWithHue:0.0 saturation:1.0 brightness:0.98],// red
							  [HeatMap archColorWithHue:0.105 saturation:1.0 brightness:0.98],// orange
							  [HeatMap archColorWithHue:0.161 saturation:1.0 brightness:0.98],// yellow
							  [HeatMap archColorWithHue:0.211 saturation:1.0 brightness:0.98],// green
							  [HeatMap archColorWithHue:0.397 saturation:1.0 brightness:0.98],// green
							  [HeatMap archColorWithHue:0.5 saturation:1.0 brightness:0.98],// blue
							  nil];
	
	NSTimeInterval future = [[NSDate distantFuture]timeIntervalSinceNow];
	NSArray *defaultWindows = [NSArray arrayWithObjects:
							   [NSNumber numberWithDouble:0],
							   [NSNumber numberWithDouble:30 * 60],
							   [NSNumber numberWithDouble:2 * 60 * 60],
							   [NSNumber numberWithDouble:24 * 60 * 60],
							   [NSNumber numberWithDouble:2 * 24 * 60 * 60],
							   [NSNumber numberWithDouble:4 * 24 * 60 * 60],
							   [NSNumber numberWithDouble:future],nil];
	
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 defaultColors,							COLORS,
								 defaultWindows,						WINDOWS,
								 nil];
	
    [defaults registerDefaults:appDefaults];
	
}
- (NSColor*) colorForInterval: (NSTimeInterval) interval
{
	for (int i = 0 ; i < [windows count];i++) {
		NSTimeInterval test = [(NSNumber*)[windows objectAtIndex:i] doubleValue];
		if (interval < test)
			return [colors objectAtIndex:i];
	}
	return [colors objectAtIndex:[colors count] - 1];
}
@end
