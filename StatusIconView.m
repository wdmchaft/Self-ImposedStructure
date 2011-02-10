//
//  StatusIconView.m
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "StatusIconView.h"
#import "WPADelegate.h"
#import "WPAMainController.h"
#import <AppKit/AppKit.h>
#import <AppKit/NSStringDrawing.h>

#define PI 3.14159265358979323846
/**
 colors:
 red h12 s83 v82
 blue 199 100 94
 grey 193 12 67
 yello 48 76 80
 orange 28 95 92
 purple 284 23 77
 green 116 48 61
 
 **/

@implementation StatusIconView
@synthesize goal;
@synthesize current;
@synthesize statusMenu;
@synthesize statusItem;
@synthesize timer;
@synthesize center;
@synthesize size_x;
@synthesize size_y;
@synthesize innerRadius;
@synthesize outerRadius;
@synthesize state;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		size_x = frame.size.width;
		size_y = frame.size.height;
		center = NSMakePoint(size_x/2, size_y/2);
		innerRadius = size_x/2 - 5;
		outerRadius = size_x/2 - 3;
		
	}
    return self;
}

- (CGFloat) calcHueForRatio: (CGFloat) ratio
{
	/** at zero we should be red (90) and at 100 we should be at orange (60) **/
	CGFloat start = 0.0;
	CGFloat end = 60.0;
	CGFloat range = start - end;
	CGFloat dist = ratio * range;
	return dist;
}

- (void) drawGradient
{
	NSRect bounds = [self bounds];
	NSColor *outerColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.0];
	NSColor *innerColor = [NSColor colorWithDeviceWhite:1.0 alpha:30.0];
	NSGradient* aGradient = [[NSGradient alloc]
							 initWithStartingColor:outerColor
							 endingColor:innerColor];
	
	NSPoint centerPoint = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
	NSPoint otherPoint = NSMakePoint(centerPoint.x + 4, centerPoint.y + 4);
	CGFloat firstRadius = MIN( ((bounds.size.width/2.0) - 2.0),
							  ((bounds.size.height/2.0) -2.0) );
	[aGradient drawFromCenter:centerPoint radius:firstRadius
					 toCenter:otherPoint radius:0.0
					  options:0];
}

- (void) drawSweepWithRadius: (int ) radius 
				   backColor: (NSColor*) redColor 
				   foreColor: (NSColor*) greenColor 
					andRatio: (float) ratio 
{	
	NSBezierPath *greenPath = [NSBezierPath bezierPath] ;
	// set some line width
	
	[greenPath setLineWidth: 0 ] ;
	
	// move to the center so that we have a closed slice
	// size_x and size_y are the height and width of the view
	
	[greenPath moveToPoint:center ] ;
	
	if (ratio > 0.0){ 
		// draw an arc 
		int startAngle = 90 - (360 * ratio);
		int endAngle = 90;
		//NSLog(@"start = %d end = %d", startAngle, endAngle);
		[greenPath appendBezierPathWithArcWithCenter: center 
											  radius: radius 
										  startAngle:startAngle
											endAngle: endAngle];
		
		// close the slice , by drawing a line to the center
		[greenPath lineToPoint: center] ;
		[greenPath stroke] ;
		
		[greenColor set] ;
		// and fill it
		[greenPath fill] ; 
	}
	
	if (ratio < 1.0){
		NSBezierPath *redPath = [NSBezierPath bezierPath];
		
		[redPath setLineWidth: 0 ] ;
		
		[redPath moveToPoint:center ] ;
		
		// draw an arc 
		//	NSLog(@"ratio = %f", ratio);
		//	NSLog(@"endAngle = %f", endAngle);
		[redPath appendBezierPathWithArcWithCenter: center 
											radius: radius 
										startAngle: -270 
										  endAngle: -270 + (360 * (1-ratio))  ] ;
		
		// close the slice , by drawing a line to the center
		[redPath lineToPoint: center ] ;
		[redPath stroke] ;
		
		[redColor set] ;
		// and fill it
		[redPath fill] ;
	}
}
-(void) dumpColor: (NSColor*) color
{
	CGFloat red,green,blue,alpha;
	CGFloat h,s,v;
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	NSLog(@"r: %f g: %f b: %f a: %f", red, green, blue, alpha);
	[color getHue:&h saturation:&s brightness:&v alpha:&alpha];
	NSLog(@"h: %f s: %f v: %f a: %f", h, s, v, alpha);
}
- (void) drawDoneness:(CGFloat) ratio
{
	CGFloat hue = [self calcHueForRatio: ratio];
	NSColor *fore = [NSColor colorWithDeviceHue:hue saturation:0.90 brightness:0.90 alpha:1];
	[self drawSweepWithRadius: outerRadius
					backColor:[NSColor whiteColor]
					foreColor:fore
					 andRatio: 1];
}
- (void) drawOff
{
	[self drawSweepWithRadius: outerRadius
					backColor:[NSColor whiteColor]
					foreColor:[NSColor blackColor]
					 andRatio: 1];
	
	
	[self drawSweepWithRadius: innerRadius 
					backColor:[NSColor whiteColor]
					foreColor:[NSColor whiteColor]
					 andRatio: 1];
}

-(void) drawLetter: (NSString*) inStr center: (NSPoint) pt
{
	NSPoint pt1 = NSMakePoint(size_x/3 ,1);
	NSSize size = NSMakeSize(size_x/2 - 1, size_y/2-1);
	NSFont *font = [NSFont systemFontOfSize:size_x * 4/7];
	NSRect rect = [font boundingRectForGlyph:[inStr characterAtIndex:0]];
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSColor whiteColor], NSForegroundColorAttributeName,
						   font, NSFontAttributeName,
						   nil];
	NSPoint newPt;
	newPt.x = pt.x - rect.size.width / 2;
	//newPt.y = (pt.y - rect.size.height / 2 )- [font descender];
	newPt.y = (pt.y - [font ascender] / 2);
	[inStr drawAtPoint:newPt withAttributes:attrs];
}
- (void) drawRect:(NSRect)dirtyRect
{
	CGFloat goalRatio = !current && !goal ? 0 : (current > goal) ? 1 : current / goal;
	if (state == WPASTATE_OFF) {
		[self drawOff];
		NSLog(@"off");	
		return;
	}
	[self drawDoneness:goalRatio];

	switch (state) {

		case WPASTATE_THINKING:
			NSLog(@"thinking");
			[self drawLetter:@"T" center:center];
			break;
		case WPASTATE_THINKTIME:
			[self drawLetter:@"T" center:center];
			break;
		case WPASTATE_FREE:
			[self drawLetter:@"F" center:center];
			break;
		case WPASTATE_AWAY:
			[self drawLetter:@"A" center:center];
			break;
		case WPASTATE_SUMMARY:
			[self drawLetter:@"?" center:center];
			break;

		default:
			break;
	}
}


/*- (void)drawRect:(NSRect)dirtyRect {
 
 CGFloat goalRatio = !current && !goal ? 0 : (current > goal) ? 1 : current / goal;
 
 // just draw a blue circle if we are off193 12 67 -- 96a7ac
 if (state == WPASTATE_OFF ){
 NSLog(@"should be grey");
 NSColor *foreColor = [NSColor colorWithDeviceHue:196 saturation:0.14 brightness:0.67 alpha:1];
 //NSColor *foreColor = [NSColor brownColor];
 [self dumpColor: foreColor];
 [self drawSweepWithRadius:outerRadius 
 backColor:[NSColor whiteColor] 
 foreColor:foreColor 
 andRatio:1.0];
 [self drawGradient];
 return;
 }
 // yellow h:48 s:76 v:80 
 if (state == WPASTATE_SUMMARY ){
 NSLog(@"should be yellow");
 NSColor *foreColor = [NSColor colorWithDeviceHue:48 saturation:0.76 brightness:0.80 alpha:1];
 //	NSColor *foreColor = [NSColor yellowColor];
 [self dumpColor: foreColor];
 [self drawSweepWithRadius:outerRadius 
 backColor:[NSColor whiteColor] 
 foreColor:foreColor
 andRatio:1.0];
 [self drawGradient];
 return;
 }
 // red h12 s83 v82
 
 if (state == WPASTATE_FREE ){
 NSLog(@"should be red");
 NSColor *foreColor = [NSColor colorWithDeviceHue:0.12 saturation:0.83 brightness:0.82 alpha:1];
 [self drawSweepWithRadius:outerRadius 
 backColor:[NSColor whiteColor] 
 foreColor:foreColor 
 andRatio:1.0];
 [self drawGradient];
 return;
 }
 if (timer) {
 NSNumber *total = timer.userInfo;
 NSTimeInterval interval = [total doubleValue] - [timer.fireDate timeIntervalSinceNow];
 CGFloat timerRatio = interval / [total doubleValue];
 [self drawSweepWithRadius: outerRadius
 backColor:[NSColor whiteColor]
 foreColor:[NSColor blueColor]
 andRatio: timerRatio];
 }
 
 [self drawSweepWithRadius: (timer ? innerRadius : outerRadius)
 backColor:[NSColor redColor]
 foreColor:[NSColor greenColor]
 andRatio: goalRatio];
 // draw the gradient
 [self drawGradient];
 }*/

- (void)mouseDown:(NSEvent *)theEvent {
    [statusItem popUpStatusItemMenu:statusMenu]; 
	
}

@end
