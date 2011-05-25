//
//  iCalTodoModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"
#import "Stateful.h"
#import "BaseTaskList.h"

@interface iCalTodoModule : BaseTaskList <Stateful> {
    NSPopUpButton *calendarMenu;
    NSTextField *refreshField;
	NSTextField *lookAheadField;
	NSTextField *calURLField;
	NSTextField *warningField;

    NSString *calendarName;
	NSMutableData *respBuffer;
	int lookAhead;
	NSStepper *stepperRefresh;
	NSStepper *stepperLookAhead;
	NSStepper *stepperWarning;
	NSDate *refreshDate;
	BOOL addThis;
	NSTimeInterval warningWindow;
	NSMutableDictionary *alarmsList;
	NSMutableDictionary *currentEvent;
	BOOL summaryMode;
	NSMutableArray *tasksList;
	id<AlertHandler> alertHandler;
    NSDateFormatter *iCalDateFmt;
    NSString *msgName;
	SEL scriptCallback;
	NSObject *completeCaller;
	SEL completeHandler;
	NSButton *isTrackedButton;
	NSButton *isWorkButton;
}
@property (nonatomic, retain) NSDate *refreshDate;
@property (nonatomic,retain) NSMutableData *respBuffer;
@property (nonatomic) NSTimeInterval warningWindow;
@property (nonatomic) int lookAhead;
@property (nonatomic) BOOL addThis;
@property (nonatomic) BOOL summaryMode;
@property (nonatomic, retain) IBOutlet NSPopUpButton *calendarMenu;
@property (nonatomic, retain) IBOutlet NSTextField *refreshField;
@property (nonatomic, retain) IBOutlet NSTextField *warningField;
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadField;
@property (nonatomic, retain) IBOutlet NSStepper *stepperRefresh;
@property (nonatomic, retain) IBOutlet NSStepper *stepperLookAhead;
@property (nonatomic, retain) IBOutlet NSStepper *stepperWarning;
@property (nonatomic, retain) IBOutlet NSButton *isWorkButton;
@property (nonatomic, retain) IBOutlet NSButton *isTrackedButton;
@property (nonatomic,retain) NSMutableDictionary *alarmsList;
@property (nonatomic,retain) NSMutableDictionary *currentEvent;
@property (nonatomic,retain) NSMutableArray *tasksList;
@property (nonatomic,retain) id<AlertHandler> alertHandler;
@property (nonatomic,retain) NSString *calendarName;
@property (nonatomic,retain) NSDateFormatter *iCalDateFmt;
@property (nonatomic,retain) NSString *msgName;
@property (nonatomic) SEL scriptCallback;
@property (nonatomic, retain) NSObject *completeCaller;
@property (nonatomic) SEL completeHandler;

//-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key;
//-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(IBAction) clickRefreshStepper: (id) sender;
-(IBAction) clickLookAheadStepper: (id) sender;
-(IBAction) clickWarningStepper: (id) sender;
- (void) handleWarningAlarm: (NSTimer*) theTimer;
-(NSString*) timeStrFor:(NSDate*) date;
@end
