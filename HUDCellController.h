//
//  HUDCellController.h
//  WorkPlayAway
//
//  Created by Charles on 6/24/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SummaryViewController.h"

@interface HUDCellTitleView : NSView {
	NSFont *font;
	NSString *title;
	NSImage *altImage;
}
@property (nonatomic, retain) NSFont *font;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSImage *altImage;
@end

@interface HUDCellController : NSViewController {
	HUDCellTitleView *titleView;
	NSView *dataView;
	SummaryViewController *dataController;
}

@property (nonatomic, retain) IBOutlet HUDCellTitleView *titleView;
@property (nonatomic, retain) IBOutlet NSView *dataView;
@property (nonatomic, retain) SummaryViewController *dataController;
@end
