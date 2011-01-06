//
//  GCalModule.h
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseModule.h"
#import "CalDAVParserDelegate.h"

@interface GCalModule : BaseModule <CalDAVParserDelegate>{
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
	NSTimeInterval refresh;
	int lookAhead;
	NSString *summaryStr;
	NSString *eventDescStr;
	BOOL titleDone;
	BOOL summaryDone;
	BOOL idDone;
	NSTimer *refreshTimer;
	NSStepper *stepperRefresh;
	NSStepper *stepperLookAhead;
	NSStepper *stepperWarning;
	NSDate *refreshDate;
	NSDate *eventDate;
	NSString *locationStr;
	BOOL addThis;
	NSTimeInterval warningWindow;
	NSMutableArray *alarmsList;
}
@property (nonatomic,retain) NSString *userStr;
@property (nonatomic,retain) NSString *calURLStr;
@property (nonatomic,retain) NSString *summaryStr;
@property (nonatomic,retain) NSString *locationStr;
@property (nonatomic,retain) NSString *eventDescStr;
@property (nonatomic,retain) NSString *passwordStr;
@property (nonatomic, retain) NSDate *refreshDate;
@property (nonatomic,retain) NSMutableData *respBuffer;
@property (nonatomic) NSTimeInterval refresh;
@property (nonatomic) NSTimeInterval warningWindow;
@property (nonatomic) int lookAhead;
@property (nonatomic) BOOL addThis;
@property (nonatomic, retain) NSDate *eventDate;
@property (nonatomic, retain) NSTimer *refreshTimer;
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

//-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key;
//-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(void) scheduleNextRefresh;
-(IBAction) clickRefreshStepper: (id) sender;
-(IBAction) clickLookAheadStepper: (id) sender;
-(IBAction) clickWarningStepper: (id) sender;
-(BOOL) isInLookAhead: (NSDate*) date;
-(void) refreshData: (NSTimer*) theTimer;
- (void) handleWarningAlarm: (NSTimer*) theTimer;


@end
