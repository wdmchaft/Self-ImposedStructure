//
//  GCalModule.h
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseInstance.h"
#import "CalDAVParserDelegate.h"
#import "Reporter.h"

@interface GCalModule : BaseInstance <CalDAVParserDelegate, Reporter>{
	NSTextField *userField;
	NSSecureTextField *passwordField;
	NSTextField *refreshField;
	NSTextField *lookAheadField;
	NSTextField *calURLField;
	NSTextField *warningField;
	NSString* userStr;
	NSString *passwordStr;
	NSString *calURLStr;
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
	<AlertHandler> alertHandler;
}
@property (nonatomic,retain) NSString *userStr;
@property (nonatomic,retain) NSString *calURLStr;
@property (nonatomic,retain) NSString *passwordStr;
@property (nonatomic, retain) NSDate *refreshDate;
@property (nonatomic,retain) NSMutableData *respBuffer;
@property (nonatomic) NSTimeInterval warningWindow;
@property (nonatomic) int lookAhead;
@property (nonatomic) BOOL addThis;
@property (nonatomic) BOOL summaryMode;
@property (nonatomic, retain) IBOutlet NSTextField *userField;
@property (nonatomic, retain) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, retain) IBOutlet NSTextField *refreshField;
@property (nonatomic, retain) IBOutlet NSTextField *calURLField;
@property (nonatomic, retain) IBOutlet NSTextField *warningField;
@property (nonatomic, retain) IBOutlet NSTextField *lookAheadField;
@property (nonatomic, retain) IBOutlet NSStepper *stepperRefresh;
@property (nonatomic, retain) IBOutlet NSStepper *stepperLookAhead;
@property (nonatomic, retain) IBOutlet NSStepper *stepperWarning;
@property (nonatomic,retain) NSMutableArray *alarmsList;
@property (nonatomic,retain) NSMutableDictionary *currentEvent;
@property (nonatomic,retain) NSMutableArray *eventsList;
@property (nonatomic,retain) <AlertHandler> alertHandler;

//-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key;
//-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(IBAction) clickRefreshStepper: (id) sender;
-(IBAction) clickLookAheadStepper: (id) sender;
-(IBAction) clickWarningStepper: (id) sender;
-(BOOL) isInLookAhead: (NSDate*) date;
-(void) refreshData;
- (void) handleWarningAlarm: (NSTimer*) theTimer;
- (void) processEvents;
-(NSString*) timeStrFor:(NSDate*) date;
@end
