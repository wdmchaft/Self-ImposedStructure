//
//  AddActivityDialogController.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/31/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskList.h"

@interface AddActivityDialogController : NSWindowController <NSComboBoxDataSource>{
	NSPopUpButton		*listsCombo;
	NSProgressIndicator *busy;
	NSButton			*okButton;
	NSButton			*cancelButton;
	NSButton			*switchNowButton;
	NSTextField			*taskField;
	NSArray				*allLists;
	id<TaskList>		taskList;
}

@property (nonatomic, retain) IBOutlet NSPopUpButton		*listsCombo;
@property (nonatomic, retain) IBOutlet NSButton				*okButton;
@property (nonatomic, retain) IBOutlet NSButton				*cancelButton;
@property (nonatomic, retain) IBOutlet NSTextField			*taskField;
@property (nonatomic, retain) IBOutlet NSProgressIndicator	*busy;
@property (nonatomic, retain) IBOutlet NSButton				*switchNowButton;
@property (nonatomic, retain) id<TaskList>					taskList;
@property (nonatomic, retain) NSArray						*allLists;

- (IBAction) clickOK: (id) sender;
- (IBAction) clickCancel: (id) sender;


@end
