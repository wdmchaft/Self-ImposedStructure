//
//  StatusIconView.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"

@interface StatusIconView : NSView {
	NSTimeInterval goal;
	NSTimeInterval work;
	NSTimeInterval free;
	NSTimer *timer;
	NSMenu *statusMenu;
	NSStatusItem *statusItem;
	NSPoint center;
	CGFloat size_x;
	CGFloat size_y;
	CGFloat innerRadius;
	CGFloat outerRadius;
	WPAStateType state;
}
@property (nonatomic) NSTimeInterval goal;
@property (nonatomic) NSTimeInterval free;
@property (nonatomic) NSTimeInterval work;
@property (nonatomic, retain) NSMenu *statusMenu;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) NSPoint center;
@property (nonatomic) CGFloat size_y;
@property (nonatomic) CGFloat size_x;
@property (nonatomic) CGFloat outerRadius;
@property (nonatomic) CGFloat innerRadius;
@property (nonatomic) WPAStateType state;
@end
