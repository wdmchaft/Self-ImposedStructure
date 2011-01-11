//
//  StatsWindow.h
//  Nudge
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SummaryTable.h"
#import "WorkTable.h"

@interface StatsWindow : NSWindowController {
	NSButton *resetButton;

	NSTableView *summaryTable;
	NSTableView *workTable;
	NSArray* statsArray;
	NSArray* workArray;
	SummaryTable *statsData;
	WorkTable *workData;
	NSTabView *tabs;
}
@property (nonatomic,retain) IBOutlet NSButton *resetButton;
@property (nonatomic,retain) IBOutlet NSTableView *summaryTable;
@property (nonatomic,retain) IBOutlet NSTableView *workTable;

@property (nonatomic,retain) NSArray *statsArray;
@property (nonatomic,retain) NSArray *workArray;
@property (nonatomic,retain) StatsTable *statsData;
@property (nonatomic,retain) WorkTable *workData;
-(IBAction) clickClear: (id) sender;
-(void) setContents;
@end
