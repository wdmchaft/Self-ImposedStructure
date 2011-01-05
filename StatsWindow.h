//
//  StatsWindow.h
//  Nudge
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatsWindow : NSWindowController {
	NSButton *resetButton;
	NSTextField *workText;
	NSTextField *playText;
	NSTextField *awayText;
	NSTableView *detailTable;
}
@property (nonatomic,retain) IBOutlet NSButton *resetButton;
@property (nonatomic,retain) IBOutlet NSTextField *workText;
@property (nonatomic,retain) IBOutlet NSTextField *playText;
@property (nonatomic,retain) IBOutlet NSTextField *awayText;
@property (nonatomic,retain) IBOutlet NSTableView *detailTable;
-(IBAction) clickClear: (id) sender;
-(void) setContents;
@end
