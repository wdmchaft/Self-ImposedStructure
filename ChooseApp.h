//
//  ChooseApp.h
//  Self-Imposed Structure
//
//  Created by Charles on 2/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ChooseApp : NSWindowController {
	NSPopUpButton *popUpRunningApps;
	NSButton *buttonOk;
	NSButton *buttonCancel;
	NSArray *allApps;
	NSRunningApplication *chosenApp;
}
@property (nonatomic,retain) IBOutlet NSPopUpButton *popUpRunningApps;
@property (nonatomic,retain) IBOutlet NSButton *buttonOk;
@property (nonatomic,retain) IBOutlet NSButton *buttonCancel;
@property (nonatomic, retain) NSArray *allApps;
@property (nonatomic, retain) NSRunningApplication *chosenApp;

- (IBAction) clickOk: (id) sender;
- (IBAction) clickCancel: (id) sender;
@end
