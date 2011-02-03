//
//  StatusIconView.h
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatusIconView : NSView {
	NSTimeInterval goal;
	NSTimeInterval current;
	NSTimer *timer;
	NSMenu *statusMenu;
	NSStatusItem *statusItem;
	NSPoint center;
	CGFloat size_x;
	CGFloat size_y;
	CGFloat innerRadius;
	CGFloat outerRadius;
}
@property (nonatomic) NSTimeInterval goal;
@property (nonatomic) NSTimeInterval current;
@property (nonatomic, retain) NSMenu *statusMenu;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) NSPoint center;
@property (nonatomic) CGFloat size_y;
@property (nonatomic) CGFloat size_x;
@property (nonatomic) CGFloat outerRadius;
@property (nonatomic) CGFloat innerRadius;
@end
