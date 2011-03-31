//
//  IOHandler.h
//  WorkPlayAway
//
//  Created by Charles on 3/3/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "TaskInfo.h"
#import "SummaryRecord.h"

@interface WriteHandler : NSObject {
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	BOOL stopMe;
	NSManagedObject *currentSummary;
	NSError *error;
	NSApplicationTerminateReply reply;
    NSArray *activities;
    NSDate *activityDate;
    NSCalendar *gregorianCal;
    NSManagedObject *summary;
}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL stopMe;
@property (nonatomic,retain) NSError *error;
@property (nonatomic) NSApplicationTerminateReply reply;
@property (nonatomic, retain) NSManagedObject *currentSummary;
@property (nonatomic, retain) NSArray *activities;
@property (nonatomic, retain) NSDate *activityDate;
@property (nonatomic, retain) NSCalendar *gregorianCal;
@property (nonatomic, retain) NSManagedObject *summary;

- (void) ioLoop: (NSObject*) param;
- (void) doWrapUp: (NSObject*) ignore;
+ (void) sendNewRecord: (WPAStateType) state;
+ (void) sendTotalsForDate: (NSDate*) date goal: (int) goalTime work: (int) workTime free: (int) freeTime;
+ (void) sendActivity: (NSDate*)date
             activity:(TaskInfo*)taskInfo
            increment:(int) incr;
+ (void) sendSummary: (SummaryRecord*) rec;

- (void) saveActivityForDate:(NSNotification*) msg;
- (void) saveActivityForDate:(NSDate*) inDate desc: (NSString*) activityName source: (NSString*) sourceName project: (NSString*) projectName addVal: (int) increment;
+ (void) sendActivity: (NSDate*)date
             activity:(TaskInfo*)taskInfo
            increment:(int) incr;
- (void) saveSummary: (SummaryRecord*) rec;

- (SummaryRecord*) getSummaryRecord;
- (void) doFlush;
@end
