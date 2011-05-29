//
//  GoogleTaskEditCtrl.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTProtocol.h"

typedef enum {
	taskActionModify, taskActionSwitch, taskActionDelete, taskActionComplete
} TaskActionType;

@interface GoogleTaskEditCtrl : NSWindowController <NSTextFieldDelegate, GTProtocolErrorDelegate> {
	NSMatrix *buttonsMatrix;
	NSTextField *titleLabel;
	NSTextField *notesLabel;
	NSTextField *listLabel;
	NSPopUpButton *listDropDown;
	NSTextField *titleEdit;
	NSDatePicker *datePicker;
	NSButton *dueToggle;
	NSProgressIndicator *prog;
	NSTextField *notesEdit;
	GTProtocol *protocol;
	NSMutableDictionary *task;
	TaskActionType okAction;
	NSTextField *nilDateLabel;
	NSView *saveView;
	NSView *baseView;
	NSString *newListId;
}
@property (nonatomic, retain) IBOutlet NSMatrix *buttonsMatrix;
@property (nonatomic, retain) IBOutlet NSTextField *titleLabel;
@property (nonatomic, retain) IBOutlet NSTextField *notesLabel;
@property (nonatomic, retain) IBOutlet NSTextField *listLabel;
@property (nonatomic, retain) IBOutlet NSPopUpButton *listDropDown;
@property (nonatomic, retain) IBOutlet NSTextField *titleEdit;
@property (nonatomic, retain) IBOutlet NSTextField *notesEdit;
@property (nonatomic, retain) IBOutlet NSDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet NSButton *dueToggle;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *prog;
@property (nonatomic, retain) IBOutlet NSTextField *nilDateLabel;
@property (nonatomic, retain) IBOutlet NSView *baseView;
@property (nonatomic, retain) GTProtocol *protocol;
@property (nonatomic, retain) NSMutableDictionary *task;
@property (nonatomic, assign) TaskActionType okAction;
@property (nonatomic, retain) NSView *saveView;
@property (nonatomic, retain) NSString *newListId;

- (IBAction) clickOK: (id) sender;
- (IBAction) clickCancel: (id) sender;
- (IBAction) clickModify: (id) sender;
- (IBAction) clickDelete: (id) sender;
- (IBAction) clickSwitch: (id) sender;
- (IBAction) clickComplete: (id) sender;
- (IBAction) clickDue: (id) sender;
- (IBAction) listChanged: (id) sender;
- (IBAction) dateChanged: (id) sender;

- (id)initWithWindowNibName:(NSString*)nibName usingProtocol: (GTProtocol*) mod forTask: (NSDictionary*) params;

@end
