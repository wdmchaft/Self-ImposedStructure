//
//  TimerDialogController.h
//  Nudge
//
//  Created by Charles on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TimerDialogController : NSWindowController {
	NSTextField *minutesField;
	NSPopUpButton *alarmNames;
	NSButton *okButton;

}

@property (retain, nonatomic) IBOutlet NSButton* okButton;
@property (retain, nonatomic) IBOutlet NSPopUpButton* alarmNames;
@property (retain, nonatomic) IBOutlet NSTextField* minutesField;

- (IBAction) okClicked: (id) sender;
- (void) loadSoundNames;
@end
