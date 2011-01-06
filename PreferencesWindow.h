//
//  PreferencesWindow.h
//  Nudge
//
//  Created by Charles on 1/1/11.
//  Copyright 2011 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddModWinController.h"

@interface PreferencesWindow : NSWindowController {
	
	NSView *workView;
	NSTableView *modulesTable;
	ModulesTableData *tableData;
	NSButton *startOnLaunchButton;
	NSButton *launchOnBootButton;
	NSTextField *growlIntervalText;
	NSButton *addButton;
	NSButton *removeButton;
	NSButton *editButton;
	NSView *newModuleView;
	AddModWinController *amwControl;
	NSStepper *growlStepper;
	NSButton *ignoreSaverButton;
}
@property (retain, nonatomic) IBOutlet NSTableView *modulesTable;
@property (retain, nonatomic) IBOutlet NSButton *addButton;
@property (retain, nonatomic) IBOutlet NSButton *removeButton;
@property (retain, nonatomic) IBOutlet NSButton *editButton;
@property (retain, nonatomic) IBOutlet NSButton *launchOnBootButton;
@property (retain, nonatomic) IBOutlet NSButton *startOnLaunchButton;
@property (retain, nonatomic) IBOutlet NSTextField *growlIntervalText;
@property (retain, nonatomic) IBOutlet NSView *newModuleView;
@property (retain, nonatomic) IBOutlet AddModWinController *amwControl;
@property (retain, nonatomic)  ModulesTableData *tableData;
@property (retain, nonatomic) IBOutlet NSStepper *growlStepper;
@property (retain, nonatomic) IBOutlet NSButton *ignoreSaverButton;

- (IBAction) clickAdd: (id) sender;
- (IBAction) clickRemove: (id) sender;
- (IBAction) clickEdit: (id) sender;
- (IBAction) clickStartOnLaunch: (id) sender;
- (IBAction) clickLaunchOnBoot: (id) sender;
- (IBAction) clickGrowlStepper: (id) sender;
- (IBAction) clickIgnoreSaverButton: (id) sender;
-(IBAction) toggleModule: (id)sender;
-(void) addToLogin;
-(void) removeFromLogin;

@end
