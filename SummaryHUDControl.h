//
//  SummaryHudControl.h
//  WorkPlayAway
//
//  Created by Charles on 1/18/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlertHandler.h"
#import "SummaryEventData.h"
#import "SummaryTaskData.h"
#import "SummaryMailData.h"
#import "SummaryDeadlineData.h"
#import "WPAMainController.h"

@interface SummaryHUDControl : NSWindowController <AlertHandler> {
	NSMutableArray* _alertList;
	int finishedCount;
	int doneCount;
	NSTextField *tempView;
	NSTableView *deadlinesTable;
	NSTableView *mailTable;
	NSTableView *tasksTable;
	NSTableView *eventsTable;
	NSProgressIndicator *progInd;

	SummaryEventData *eventsData;
	SummaryDeadlineData *deadlinesData;
	SummaryTaskData *tasksData;
	SummaryMailData *mailsData;
	WPAMainController *mainControl;
	<TaskList> *currentList;
	NSTableView *currentTable;
}

@property (nonatomic) int finishedCount;
@property (nonatomic) int doneCount;
@property (nonatomic, retain) IBOutlet NSTableView *deadlinesTable;
@property (nonatomic, retain) IBOutlet NSTableView *eventsTable;
@property (nonatomic, retain) IBOutlet NSTableView *mailTable;
@property (nonatomic, retain) IBOutlet NSTableView *tasksTable;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progInd;
@property (nonatomic, retain)  SummaryDeadlineData *deadlinesData;
@property (nonatomic, retain)  SummaryEventData *eventsData;
@property (nonatomic, retain)  SummaryMailData *mailsData;
@property (nonatomic, retain)  SummaryTaskData *tasksData;
@property (nonatomic, retain)  WPAMainController *mainControl;
@property (nonatomic, retain)  <TaskList> *currentList;
@property (nonatomic, retain) NSTableView *currentTable;
- (void) processSummary;
- (void) allSummaryDataReceived;
- (void) handleDouble: (id) sender;
- (IBAction) checkTask: (id) sender;

@end
