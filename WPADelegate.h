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

@interface WPADelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	PreferencesWindow *prefsWindow;
	StatsWindow *statsWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) PreferencesWindow *prefsWindow;
@property (retain, nonatomic) IBOutlet StatsWindow *statsWindow;

//-(void) start;
//-(void) stop;

//-(NSArray*) getAllTasks;
-(NSString*) entityNameForState: (int) state;
- (NSManagedObject*) findTask: (NSString*) name inContext: (NSManagedObjectContext*) moc;
- (NSManagedObject*) findSource: (NSString*) name inContext: (NSManagedObjectContext*) moc;
-(void) newRecord:(int)state;
- (void) refreshTasks;
- (IBAction) removeStore: (id) sender;
- (double) countEntity: (NSString*) eName inContext: (NSManagedObjectContext*) moc;
- (NSString*) dumpMObj: (NSManagedObject*) obj;
- (BOOL) hasTask: (NSManagedObject*) mobj;

-(IBAction) clickPreferences: (id) sender;
-(IBAction) clickTasksInfo: (id) sender;
-(IBAction)handleNewMainWindowMenu:(NSMenuItem *)sender;

@end
