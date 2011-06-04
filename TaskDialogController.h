//
//  TaskDialogController.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/6/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMProtocol.h"
#import "TimelineHandler.h"

typedef enum {
	taskActionModify, taskActionSwitch, taskActionDelete, taskActionComplete
} actionType;

typedef enum {
	updateName, updateDate, updateNote, updateDone
} updateStep;

@interface UpdateSteps : NSObject
{
	@private
	NSMutableArray *steps;
}
@property (nonatomic, retain) NSMutableArray *steps;

- (void) addStep: (updateStep) step;
- (updateStep) getStep;
- (void) popStep;

@end

@interface TaskDialogController : NSWindowController <NSTextFieldDelegate> {
	NSMatrix *buttonsMatrix;
	NSButton *dueButton;
	NSButton *okButton;
	NSButton *cancelButton;
	NSProgressIndicator *busyIndicator;
	NSTextField *nameField;
	NSTextField *notesField;
	NSDatePicker *dueDatePicker;
	NSPopUpButton *listsCombo;
	NSDictionary *tdc;
	RTMProtocol *context;
	TimelineHandler *tlHandler;
	actionType currentJob;
	NSTextField *nilDateLabel;
	NSView *saveView;
	NSView *baseView;
	NSTextField *listLabel;
	NSTextField *titleLabel;
	NSTextField *notesLabel;
	UpdateSteps *updateSteps;
}
@property (nonatomic,retain) IBOutlet NSMatrix *buttonsMatrix;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *busyIndicator;
@property (nonatomic,retain) IBOutlet NSButton *dueButton;
@property (nonatomic,retain)  NSDictionary *tdc;
@property (nonatomic,retain)  RTMProtocol *context;
@property (nonatomic,retain)  TimelineHandler *tlHandler;
@property (nonatomic,retain) IBOutlet NSTextField *nameField;
@property (nonatomic,retain) IBOutlet NSTextField *notesField;
@property (nonatomic,retain) IBOutlet NSDatePicker *dueDatePicker;
@property (nonatomic,retain) IBOutlet NSPopUpButton *listsCombo;
@property (nonatomic,retain) IBOutlet NSTextField *nilDateLabel;
@property (nonatomic,retain) IBOutlet NSTextField *listLabel;
@property (nonatomic,retain) IBOutlet NSTextField *titleLabel;
@property (nonatomic,retain) IBOutlet NSTextField *notesLabel;
@property (nonatomic,retain) IBOutlet NSView *saveView;
@property (nonatomic,retain) IBOutlet NSView *baseView;
@property (nonatomic) actionType currentJob;
@property (nonatomic, retain) UpdateSteps *updateSteps;

- (IBAction) clickUpdate: (id)sender;
- (IBAction) clickComplete: (id)sender;
- (IBAction) clickDelete: (id)sender;
- (IBAction) clickOk: (id)sender;
- (IBAction) clickCancel: (id)sender;
- (IBAction) clickSwitch: (id)sender;
- (IBAction) clickDue: (id)sender;
- (IBAction) listChanged: (id) sender;
- (IBAction) dateChanged: (id) sender;

- (void) sendComplete;
- (void) sendDelete;
- (void) simpleDone;


-(TaskDialogController*)initWithWindowNibName:(NSString*)nibName andContext: (RTMProtocol*) mod andParams: (NSDictionary*) ctx;
- (void) loadLists;

@end
