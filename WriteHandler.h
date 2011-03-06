//
//  IOHandler.h
//  WorkPlayAway
//
//  Created by Charles on 3/3/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"

@interface WriteHandler : NSObject {
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	BOOL stopMe;
	NSManagedObject *currentSummary;
	NSError *error;
	NSApplicationTerminateReply reply;
}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL stopMe;
@property (nonatomic,retain) NSError *error;
@property (nonatomic) NSApplicationTerminateReply reply;
@property (nonatomic, retain) NSManagedObject *currentSummary;

- (void) ioLoop: (NSObject*) param;
- (void) doWrapUp: (NSObject*) ignore;
+ (void) sendNewRecord: (WPAStateType) state;
+ (void) sendSummaryForDate: (NSDate*) date goal: (int) goalTime work: (int) workTime free: (int) freeTime;
@end
