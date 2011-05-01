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
#define JOB_DELETE 0
#define JOB_COMPLETE 1
#define JOB_MOVETO 2
#define JOB_NONE 3

@interface TaskDialogController : NSWindowController {
	NSButton *dismissButton;
	NSButton *okButton;
	NSButton *cancelButton;
	NSProgressIndicator *busyIndicator;
	NSTextField *nameField;
	NSTextFieldCell *notesField;
	NSDatePicker *dueDatePicker;
	NSComboBox *listsCombo;
	NSDictionary *tdc;
	RTMProtocol *context;
	TimelineHandler *tlHandler;
	int currentJob;
}
@property (nonatomic,retain) IBOutlet NSProgressIndicator *busyIndicator;
@property (nonatomic,retain) IBOutlet NSButton *dismissButton;
@property (nonatomic,retain)  NSDictionary *tdc;
@property (nonatomic,retain)  RTMProtocol *context;
@property (nonatomic,retain)  TimelineHandler *tlHandler;
@property (nonatomic,retain) IBOutlet NSTextField *nameField;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *notesField;
@property (nonatomic,retain) IBOutlet NSDatePicker *dueDatePicker;
@property (nonatomic,retain) IBOutlet NSComboBox *listsCombo;
@property (nonatomic) int currentJob;

- (IBAction) clickDismiss: (id)sender;
- (IBAction) clickComplete: (id)sender;
- (IBAction) clickDelete: (id)sender;
- (IBAction) clickOk: (id)sender;
- (IBAction) clickCancel: (id)sender;
- (IBAction) listChanged: (id)sender;


- (void) sendComplete;
- (void) sendDelete;
- (void) rmDone;


-(TaskDialogController*)initWithWindowNibName:(NSString*)nibName andContext: (RTMProtocol*) mod andParams: (NSDictionary*) ctx;
- (void) loadLists;

@end
