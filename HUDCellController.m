//
//  HUDCellController.m
//  Self-Imposed Structur
//
//  Created by Charles on 6/24/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "HUDCellController.h"


@implementation HUDCellController
@synthesize titleView, dataView, dataController;
@end

@implementation HUDCellTitleView
@synthesize font, title, altImage;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[self setToolTip:title];
	NSRect dRect = dirtyRect;
//	NSLog(@"dRect height = %f", dRect.size.height);
	if (dRect.size.height < 40.0){
	//	NSRect rect = [self frame];
		NSImageView *iView = [[NSImageView alloc]initWithFrame:NSMakeRect(3, 0, dRect.size.width-7, dRect.size.width-7)];
		[self addSubview:iView];
		[altImage setSize:NSMakeSize(14, 14)];
		[iView setImage:altImage];
		return;
	}

	NSAffineTransform *xform = [[NSAffineTransform alloc] init];
	
	[xform translateXBy: 17.0 yBy: 0.0];
	[xform rotateByDegrees: 90.0];
	[xform concat]; 
	
	NSColor *labelColor = [NSColor colorWithDeviceHue:0.0 saturation:0.0 brightness:0.80 alpha:1.0];
	NSDictionary *labelAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
								labelColor, NSForegroundColorAttributeName,
								font, NSFontAttributeName,
								nil];
	NSRect rect = [title  boundingRectWithSize:dRect.size 
										 options:0 
									  attributes:labelAttrs];
	CGFloat shift = (dRect.size.height - rect.size.width) / 2;

	NSPoint newPt;
	newPt.x = shift;
	newPt.y = 0;
	[title drawAtPoint:newPt withAttributes:labelAttrs];
}
@end