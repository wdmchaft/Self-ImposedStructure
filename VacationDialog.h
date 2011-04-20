//
//  VacationDialog.h
//  WorkPlayAway
//
//  Created by Charles on 4/11/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VacationDialog : NSWindowController {
@private
	NSDatePicker *endPicker;
	NSButton *okButton;
	NSButton *cancelButton;
	BOOL onVacation;
}

@property (nonatomic,retain) IBOutlet NSDatePicker *endPicker;
@property (nonatomic) BOOL onVacation;

- (IBAction) clickOk: (id) sender;
- (IBAction) clickCancel: (id) sender;

@end
