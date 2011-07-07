//
//  PreferencesWindow.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/1/11.
//  Copyright 2011 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddModWinController.h"
#import "NDHotKeyControl.h"

@interface PreferencesWindow : NSWindowController <NSTextFieldDelegate>{
	
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
	NDHotKeyControl *hkControl;
	NSButton *useHKButton;
	NSButton *preHKButton;
	NSObject *hkTarget;
	SEL hkSelector;
	BOOL gotKey;
}

@property (retain, nonatomic) IBOutlet NDHotKeyControl *hkControl;
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
@property ( nonatomic) BOOL gotKey;
@property (retain, nonatomic) IBOutlet NSStepper *summaryStepper;
@property (retain, nonatomic) IBOutlet NSTextField *summaryField;
@property (retain, nonatomic) IBOutlet NSTextField *summaryLabel;
@property (retain, nonatomic) IBOutlet NSTextField *summaryLabel2;
@property (retain, nonatomic) IBOutlet NSButton *summaryButton;
@property (retain, nonatomic) IBOutlet NSButton *useHKButton;
@property (retain, nonatomic) IBOutlet NSButton *preHKButton;
@property (retain, nonatomic) NSObject *hkTarget;
@property (nonatomic) SEL hkSelector;

- (IBAction) clickAdd: (id) sender;
- (IBAction) clickRemove: (id) sender;
- (IBAction) clickEdit: (id) sender;
- (IBAction) clickLaunchOnBoot: (id) sender;
-(IBAction) toggleModule: (id)sender;
-(BOOL) addToLogin;
-(BOOL) removeFromLogin;

- (void) addClosed: (NSNotification*) notification;

- (IBAction) clickSummary: (id) sender;
- (IBAction) clickUseHotKey: (id) sender;
- (IBAction) clickPreHK: (id) sender;
- (IBAction) hotKeyPicked: (id) sender;
@end
