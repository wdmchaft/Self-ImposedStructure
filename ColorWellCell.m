//
//  ColorWellCell.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/25/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "ColorWellCell.h"


@implementation ColorWellCell

- (id)init
{
    self = [super init];
    if (self) {
        [super setObjectValue:[NSColor whiteColor]];
        [super sendActionOn:NSLeftMouseUp];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction) colorPicked: (NSNotification*) msg
{
    [NSApp stopModal];
    [super setObjectValue:[NSColorPanel sharedColorPanel].color];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];   
}

- (IBAction) colorEdit
{
    NSColorPanel *cp = [NSColorPanel sharedColorPanel];
    [cp setColor:(NSColor*)super.objectValue];
    [cp setAction:@selector(colorPicked:)];
    [cp setTarget:self];
    
    [cp makeKeyAndOrderFront:self];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(colorPicked:) name:NSWindowWillCloseNotification object:cp];

    [NSApp runModalForWindow:cp];

}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{

    NSRect innerRect;
    
    NSColor *clr = (NSColor*)[super objectValue];
    if (!clr){
        clr = [NSColor whiteColor];
    }
    innerRect = cellFrame;
    innerRect.size.height -= 4;
    innerRect.size.width -= 4;
    innerRect.origin.x += 2;
    innerRect.origin.y += 2;
 // + (NSBezierPath *)bezierPathWithRect:(NSRect)aRect  
    NSBezierPath *innerPath = [NSBezierPath bezierPathWithRect:innerRect];
    [[NSColor blackColor] set];
    [innerPath stroke];
    [clr set];
    [innerPath fill];
}

-(BOOL) trackMouse:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)view untilMouseUp:(BOOL)mouseUp
{
    //NSLog(@"trackMouse mouseUp = %d", mouseUp);

    return [super trackMouse:event inRect: cellFrame ofView:view untilMouseUp: mouseUp];
}

- (BOOL) startTrackingAt: (NSPoint) point inView: (NSView*) view
{
    //NSLog(@"startTracking");
    [self performSelector:@selector(colorEdit)];
    
   return [super startTrackingAt: point inView: view];
}

- (BOOL) continueTracking:(NSPoint)last  at:(NSPoint)point inView:(NSView *)view
{
    //NSLog(@"continueTracking");
    return [super continueTracking: last at:point inView: view];

}

- (void) stopTracking: (NSPoint) last at:(NSPoint)stop inView:(NSView *)view mouseIsUp:(BOOL)isUp
{
    //NSLog(@"stopTracking mouseUp=%d", isUp);
    return [super stopTracking: last at:stop inView: view mouseIsUp: isUp];
}

//- (void)stopTracking:(NSPoint)lastPoint 
//                  at:(NSPoint)stopPoint 
//              inView:(NSView *)controlView 
//           mouseIsUp:(BOOL)upFlag
//{
//    if (upFlag){
//        
//    }
//}
@end
