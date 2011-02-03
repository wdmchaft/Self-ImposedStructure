//
//  AddActivityDialogController.h
//  WorkPlayAway
//
//  Created by Charles on 1/31/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AddActivityDialogController : NSWindowController {
	NSComboBox  *activityCombo;
	NSButton	*okButton;
	NSButton	*cancelButton;
}

@property (nonatomic, retain) IBOutlet NSComboBox	*activityCombo;
@property (nonatomic, retain) IBOutlet NSButton		*okButton;
@property (nonatomic, retain) IBOutlet NSButton		*cancelButton;

- (IBAction) clickOK: (id) sender;
- (IBAction) clickCancel: (id) sender;


@end
