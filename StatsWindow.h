//
//  StatsWindow.h
//  Nudge
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "StatsTable.h"

@interface StatsWindow : NSWindowController {
	NSButton *resetButton;
	NSTextField *workText;
	NSTextField *playText;
	NSTextField *awayText;
	NSTableView *detailTable;
	NSArray* statsArray;
	StatsTable *statsData;
}
@property (nonatomic,retain) IBOutlet NSButton *resetButton;
@property (nonatomic,retain) IBOutlet NSTextField *workText;
@property (nonatomic,retain) IBOutlet NSTextField *playText;
@property (nonatomic,retain) IBOutlet NSTextField *awayText;
@property (nonatomic,retain) IBOutlet NSTableView *detailTable;

@property (nonatomic,retain) NSArray *statsArray;
@property (nonatomic,retain) StatsTable *statsData;
-(IBAction) clickClear: (id) sender;
-(void) setContents;
@end
