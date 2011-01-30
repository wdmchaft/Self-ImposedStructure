//
//  StatusIconView.m
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "StatusIconView.h"
#define PI 3.14159265358979323846


@implementation StatusIconView
@synthesize goal;
@synthesize current;
@synthesize statusMenu;
@synthesize statusItem;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}
// green is 
- (void)drawRect:(NSRect)dirtyRect {

	CGFloat ratio = (current > goal) ? 1 : current / goal;
	NSBezierPath *greenPath = [NSBezierPath bezierPath] ;
	
	CGFloat size_x = dirtyRect.size.width;
	CGFloat size_y = dirtyRect.size.height;

	NSPoint center = NSMakePoint( size_x/2, size_y/2 )  ;
	
	// set some line width
	
	[greenPath setLineWidth: 0 ] ;
	
	// move to the center so that we have a closed slice
	// size_x and size_y are the height and width of the view
	
	[greenPath moveToPoint:center ] ;
	
	// draw an arc 
	[greenPath appendBezierPathWithArcWithCenter: center 
										  radius: size_x/2-2 
										startAngle:90 - (360 * ratio)
										endAngle: 90];
	
	// close the slice , by drawing a line to the center
	[greenPath lineToPoint: NSMakePoint(size_x/2, size_y/2) ] ;
	[greenPath stroke] ;
	
	[[NSColor greenColor] set] ;
	// and fill it
	[greenPath fill] ; 
	
	NSBezierPath *redPath = [NSBezierPath bezierPath];
	
	[redPath setLineWidth: 0 ] ;
	
	[redPath moveToPoint:center ] ;
	
	// draw an arc 
	CGFloat endAngle = (360 - (360 * ratio)) + 90;
	NSLog(@"ratio = %f", ratio);
	NSLog(@"endAngle = %f", endAngle);
	[redPath appendBezierPathWithArcWithCenter: center 
										radius: size_x/2-2 
									startAngle: -270 
									  endAngle: -270 + (360 * (1-ratio))  ] ;
	
	// close the slice , by drawing a line to the center
	[redPath lineToPoint: NSMakePoint(size_x/2, size_y/2) ] ;
	[redPath stroke] ;
	
	[[NSColor redColor] set] ;
	// and fill it
	[redPath fill] ; 
}

- (void)mouseDown:(NSEvent *)theEvent {
    [statusItem popUpStatusItemMenu:statusMenu]; 
}

@end
