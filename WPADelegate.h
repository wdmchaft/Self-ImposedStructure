//
//  WPADelegate.h
//  Nudge
//
//  Created by Charles on 11/17/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"
#import "AlertHandler.h"

#import "Growl.h"
#import "Context.h"
#import "PreferencesWindow.h"
#import "StatsWindow.h"
#import "WriteHandler.h"
#import "SummaryRecord.h"
#import "WPAMDelegate.h"

@interface WPADelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    NSWindow *window;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	PreferencesWindow *prefsWindow;
	StatsWindow *statsWindow;
	NSManagedObject *currentSummary;
	NSThread *ioThread;
	WriteHandler *ioHandler;
	NSMenu *statusMenu;
	id<WPAMDelegate> wpam;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) PreferencesWindow *prefsWindow;
@property (nonatomic, retain) NSManagedObject *currentSummary;
@property (retain, nonatomic) IBOutlet StatsWindow *statsWindow;
@property (retain, nonatomic) IBOutlet id<WPAMDelegate> wpam;
@property (retain, nonatomic) NSThread *ioThread;
@property (retain, nonatomic) WriteHandler *ioHandler;
//-(void) start;
//-(void) stop;

//-(NSArray*) getAllTasks;
-(NSString*) entityNameForState: (int) state;
- (NSManagedObject*) findTask: (NSString*) name inContext: (NSManagedObjectContext*) moc;
- (NSManagedObject*) findSource: (NSString*) name inContext: (NSManagedObjectContext*) moc;
- (IBAction) removeStore: (id) sender;
- (double) countEntity: (NSString*) eName inContext: (NSManagedObjectContext*) moc;
- (NSString*) dumpMObj: (NSManagedObject*) obj;
- (BOOL) hasTask: (NSManagedObject*) mobj;

- (IBAction)handleNewMainWindowMenu:(NSMenuItem *)sender;
- (BOOL) findSummaryForDate: (NSDate*) date work: (NSTimeInterval*) workInt free: (NSTimeInterval*) freeInt;
- (void) saveData: (NSTimer*) timer;
- (void) doSaveThread: (NSObject*) param;
//- (SummaryRecord*) getSummaryRecord;
@end
