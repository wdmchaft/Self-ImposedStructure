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
	NSButton *launchOnBootButton;
	NSButton *addButton;
	NSButton *removeButton;
	NSButton *editButton;
	NSView *newModuleView;
	AddModWinController *amwControl;
	
	NSModalSession editModuleSession;
}

@property (retain, nonatomic) IBOutlet NSTableView *modulesTable;
@property (retain, nonatomic) IBOutlet NSButton *addButton;
@property (retain, nonatomic) IBOutlet NSButton *removeButton;
@property (retain, nonatomic) IBOutlet NSButton *editButton;
@property (retain, nonatomic) IBOutlet NSButton *launchOnBootButton;
@property (retain, nonatomic) IBOutlet NSButton *enableHotKeyButton;
@property (retain, nonatomic) IBOutlet NSView *newModuleView;
@property (retain, nonatomic) IBOutlet AddModWinController *amwControl;
@property (retain, nonatomic)  ModulesTableData *tableData;
@property ( nonatomic) NSModalSession editModuleSession;

- (IBAction) clickAdd: (id) sender;
- (IBAction) clickRemove: (id) sender;
- (IBAction) clickEdit: (id) sender;
- (IBAction) clickLaunchOnBoot: (id) sender;
-(IBAction) toggleModule: (id)sender;
-(BOOL) addToLogin;
-(BOOL) removeFromLogin;

- (void) addClosed: (NSNotification*) notification;
- (IBAction) clickUseHotKey: (id) sender;

@end
