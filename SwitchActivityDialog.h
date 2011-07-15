//
//  SwitchActivityDialog.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskList.h"
#import "ActivityComboData.h"

@interface SwitchActivityDialog : NSWindowController {
	NSPopUpButton	*newListsButton;
	NSPopUpButton	*oldListsButton;
	NSComboBox		*oldActCombo;
	NSComboBox		*newActCombo;
	NSPopUpButton		*oldProjPopUp;
	NSPopUpButton		*newProjPopUp;
	NSButton		*okButton;
	NSButton		*cancelButton;
	NSButton		*completeButton;
	NSTextField		*currentText;
	id<TaskList>	newList;
	id<TaskList>	oldList;
	ActivityComboData *newData;
	ActivityComboData *oldData;
}
@property (nonatomic, retain) IBOutlet NSButton			*completeButton;
@property (nonatomic, retain) IBOutlet NSTextField		*currentText;
@property (nonatomic, retain) IBOutlet NSPopUpButton	*oldListsButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton	*newListsButton;
@property (nonatomic, retain) IBOutlet NSComboBox		*oldActCombo;
@property (nonatomic, retain) IBOutlet NSComboBox		*newActCombo;
@property (nonatomic, retain) IBOutlet NSPopUpButton		*oldProjPopUp;
@property (nonatomic, retain) IBOutlet NSPopUpButton		*newProjPopUp;
@property (nonatomic, retain) IBOutlet NSButton			*okButton;
@property (nonatomic, retain) IBOutlet NSButton			*cancelButton;
@property (nonatomic, retain) IBOutlet id<TaskList>				oldList;
@property (nonatomic, retain) IBOutlet id<TaskList>				newList;
@property (nonatomic, retain) IBOutlet ActivityComboData *newData;
@property (nonatomic, retain) IBOutlet ActivityComboData *oldData;

- (IBAction) clickOldLists: (id) sender;
- (IBAction) clickNewLists: (id) sender;
- (IBAction) clickOk: (id) sender;
- (IBAction) clickCancel: (id) sender;
@end
