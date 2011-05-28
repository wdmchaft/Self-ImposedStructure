//
//  SwitchActivityDialog.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskList.h"

@interface SwitchActivityDialog : NSWindowController {
	NSPopUpButton	*listsButton;
	NSComboBox		*availableActCombo;
	NSButton		*okButton;
	NSButton		*cancelButton;
	id<TaskList>	list;
}
@property (nonatomic, retain) IBOutlet NSPopUpButton	*listsButton;
@property (nonatomic, retain) IBOutlet NSComboBox		*availableActCombo;
@property (nonatomic, retain) IBOutlet NSButton			*okButton;
@property (nonatomic, retain) IBOutlet NSButton			*cancelButton;
@property (nonatomic, retain)  id<TaskList>				list;

- (IBAction) clickLists: (id) sender;
- (IBAction) clickOk: (id) sender;
- (IBAction) clickCancel: (id) sender;
@end
