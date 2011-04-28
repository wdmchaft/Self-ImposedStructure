//
//  iCalModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"

@interface iCalModule : BaseReporter{
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
	NSMutableArray *alarmsList;
	NSMutableDictionary *currentEvent;
	BOOL summaryMode;
	NSMutableArray *eventsList;
	id<AlertHandler> alertHandler;
    NSDateFormatter *iCalDateFmt;
    NSString *msgName;
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
@property (nonatomic,retain) NSMutableArray *alarmsList;
@property (nonatomic,retain) NSMutableDictionary *currentEvent;
@property (nonatomic,retain) NSMutableArray *eventsList;
@property (nonatomic,retain) id<AlertHandler> alertHandler;
@property (nonatomic,retain) NSString *calendarName;
@property (nonatomic,retain) NSDateFormatter *iCalDateFmt;
@property (nonatomic,retain) NSString *msgName;

//-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key;
//-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(IBAction) clickRefreshStepper: (id) sender;
-(IBAction) clickLookAheadStepper: (id) sender;
-(IBAction) clickWarningStepper: (id) sender;
-(void) refreshData;
- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) processEvents;
-(NSString*) timeStrFor:(NSDate*) date;
@end
