//
//  AddModWinController.h
//  Nudge
//
//  Created by Charles on 12/2/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "ModulesTableData.h"

@interface AddModWinController : NSWindowController {
	NSString *originalName;
	NSButton *okButton;
	NSButton *cancelButton;
	NSPopUpButton *typeButton;
	NSTextField *nameText;
	NSBox *configBox;
	NSView *nothingView;
	NSViewController *currCtrl;
	NSProgressIndicator *indicator;
	ModulesTableData *tableData;
	NSTableView *tableView;
	NSTableView *hudView;
	NSMutableArray *modNames;
}
@property (nonatomic, retain) IBOutlet	NSButton *okButton;
@property (nonatomic, retain) IBOutlet	NSButton *cancelButton;
@property (nonatomic, retain) IBOutlet	NSPopUpButton *typeButton;
@property (nonatomic, retain) IBOutlet	NSTextField *nameText;
@property (nonatomic, retain) IBOutlet	NSBox *configBox;
@property (nonatomic, retain) IBOutlet	NSView *nothingView;
@property (nonatomic, retain) IBOutlet	NSProgressIndicator *indicator;
@property (nonatomic, retain) ModulesTableData *tableData;
@property (nonatomic, retain) NSViewController *currCtrl;
@property (nonatomic,retain) NSTableView *tableView;
@property (nonatomic,retain) NSTableView *hudView;
@property (nonatomic,retain) NSMutableArray *modNames;
@property (nonatomic, retain) NSString * originalName;

- (IBAction) clickOk: (id) sender;
- (IBAction) clickCancel: (id) sender;
- (IBAction) clickType: (id) sender;
@end
