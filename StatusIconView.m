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
#define PI 3.14159265358979323846


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

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		size_x = frame.size.width;
		size_y = frame.size.height;
		center = NSMakePoint(size_x/2, size_y/2);
		innerRadius = size_x/2 - 5;
		outerRadius = size_x/2 - 2;
		NSLog(@"center = %f size_x = %f outerRadius = %f", center.x, size_x, outerRadius);
		
	}
    return self;
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

- (void)drawRect:(NSRect)dirtyRect {

	CGFloat goalRatio = (current > goal) ? 1 : current / goal;
	

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

}

- (void)mouseDown:(NSEvent *)theEvent {
    [statusItem popUpStatusItemMenu:statusMenu]; 

}

@end
