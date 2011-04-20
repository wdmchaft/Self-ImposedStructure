//
//  PreferencesWindow.h
//  Nudge
//
//  Created by Charles on 1/1/11.
//  Copyright 2011 zer0gravitas.com. All rights reserved.
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
	NSTableView *hudTable;
	NSTableView *heatTable;
	NSStepper *summaryStepper;
	NSTextField *summaryField;
	NSTextField *summaryLabel;
	NSTextField *summaryLabel2;
	NSButton *summaryButton;
}

@property (retain, nonatomic) IBOutlet NSTableView *modulesTable;
@property (retain, nonatomic) IBOutlet NSTableView *hudTable;
@property (retain, nonatomic) IBOutlet NSTableView *heatTable;
@property (retain, nonatomic) IBOutlet NSButton *addButton;
@property (retain, nonatomic) IBOutlet NSButton *removeButton;
@property (retain, nonatomic) IBOutlet NSButton *editButton;
@property (retain, nonatomic) IBOutlet NSButton *launchOnBootButton;
@property (retain, nonatomic) IBOutlet NSView *newModuleView;
@property (retain, nonatomic) AddModWinController *amwControl;
@property (retain, nonatomic)  ModulesTableData *tableData;
@property ( nonatomic) NSModalSession editModuleSession;
@property (retain, nonatomic) IBOutlet NSStepper *summaryStepper;
@property (retain, nonatomic) IBOutlet NSTextField *summaryField;
@property (retain, nonatomic) IBOutlet NSTextField *summaryLabel;
@property (retain, nonatomic) IBOutlet NSTextField *summaryLabel2;
@property (retain, nonatomic) IBOutlet NSButton *summaryButton;

- (IBAction) clickAdd: (id) sender;
- (IBAction) clickRemove: (id) sender;
- (IBAction) clickEdit: (id) sender;
- (IBAction) clickLaunchOnBoot: (id) sender;
-(IBAction) toggleModule: (id)sender;
-(BOOL) addToLogin;
-(BOOL) removeFromLogin;

- (void) addClosed: (NSNotification*) notification;
- (IBAction) clickUseHotKey: (id) sender;

- (IBAction) clickSummary: (id) sender;

@end
