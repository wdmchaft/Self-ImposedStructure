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
	NSMenu *statusMenu;
	NSStatusItem *statusItem;
}
@property (nonatomic) NSTimeInterval goal;
@property (nonatomic) NSTimeInterval current;
@property (nonatomic, retain) NSMenu *statusMenu;
@property (nonatomic, retain) NSStatusItem *statusItem;

@end
