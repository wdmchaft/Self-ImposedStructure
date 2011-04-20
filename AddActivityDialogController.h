//
//  AddActivityDialogController.h
//  WorkPlayAway
//
//  Created by Charles on 1/31/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AddActivityDialogController : NSWindowController <NSComboBoxDataSource>{
	NSComboBox  *activityCombo;
	NSButton	*okButton;
	NSButton	*cancelButton;
	NSArray *allActivities;
}

@property (nonatomic, retain) IBOutlet NSComboBox	*activityCombo;
@property (nonatomic, retain) IBOutlet NSButton		*okButton;
@property (nonatomic, retain) IBOutlet NSButton		*cancelButton;
@property (nonatomic, retain)		   NSArray		*allActivities;

- (IBAction) clickOK: (id) sender;
- (IBAction) clickCancel: (id) sender;


@end
