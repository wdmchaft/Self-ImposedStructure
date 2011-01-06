//
//  TaskDialogController.h
//  RTGTest
//
//  Created by Charles on 11/6/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RTMModule.h"
#import "TimelineHandler.h"
#import "RTMCallback.h"
#define JOB_DELETE 0
#define JOB_COMPLETE 1
#define JOB_MOVETO 2

@interface TaskDialogController : NSWindowController <RTMCallback> {
	NSButton *dismissButton;
	NSProgressIndicator *busyIndicator;
	NSString *timelineStr;
	NSTextField *nameField;
	NSTextFieldCell *notesField;
	NSDatePicker *dueDatePicker;
	NSComboBox *listsCombo;
	NSDictionary *tdc;
	RTMModule *context;
	TimelineHandler *tlHandler;
	int currentJob;
}
@property (nonatomic, retain) NSString *timelineStr;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *busyIndicator;
@property (nonatomic,retain) IBOutlet NSButton *dismissButton;
@property (nonatomic,retain)  NSDictionary *tdc;
@property (nonatomic,retain)  RTMModule *context;
@property (nonatomic,retain)  TimelineHandler *tlHandler;
@property (nonatomic,retain) IBOutlet NSTextField *nameField;
@property (nonatomic,retain) IBOutlet NSTextFieldCell *notesField;
@property (nonatomic,retain) IBOutlet NSDatePicker *dueDatePicker;
@property (nonatomic,retain) IBOutlet NSComboBox *listsCombo;
@property (nonatomic) int currentJob;

- (IBAction) clickDismiss: (id)sender;
- (IBAction) clickComplete: (id)sender;
- (IBAction) clickDelete: (id)sender;
- (IBAction) listChanged: (id)sender;
- (void) timelineRequest;

- (void) getLists;
- (void) sendComplete;
- (void) sendDelete;
- (void) rmDone;


-(TaskDialogController*)initWithWindowNibName:(NSString*)nibName andContext: (RTMModule*) mod andParams: (NSDictionary*) ctx;
- (void) loadLists;

@end
