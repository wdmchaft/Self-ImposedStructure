//
//  WPADelegate.h
//  Nudge
//
//  Created by Charles on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"
#import "AlertHandler.h"

#import "Growl.h"
#import "Context.h"
#import "PreferencesWindow.h"
#import "StatsWindow.h"

@interface WPADelegate : NSObject <NSApplicationDelegate, 
										AlertHandler, GrowlApplicationBridgeDelegate> {
    NSWindow *window;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	PreferencesWindow *prefsWindow;
	StatsWindow *statsWindow;

}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) PreferencesWindow *prefsWindow;
@property (retain, nonatomic) IBOutlet StatsWindow *statsWindow;

-(void) goAway;
-(void) start;
-(void) stop;
-(void) think: (int) minutes;
-(void) run;
-(void) setState: (int) state;


-(void) growlAlert: (Note*) alert;
- (void) growlNotificationWasClicked:(id)ctx;
-(NSArray*) getAllTasks;
-(void) registerTasksHandler:(id) handler;
-(NSString*) entityNameForState: (int) state;
- (NSManagedObject*) findTask: (NSString*) name inContext: (NSManagedObjectContext*) moc;
-(void) newRecord:(int)state;
- (void) refreshTasks;
- (IBAction) removeStore: (id) sender;
- (double) countEntity: (NSString*) eName inContext: (NSManagedObjectContext*) moc;
- (NSString*) dumpMObj: (NSManagedObject*) obj;
- (BOOL) hasTask: (NSManagedObject*) mobj;
-(void) handleNotification:(NSNotification *)notification;

-(IBAction) clickPreferences: (id) sender;
-(IBAction) clickTasksInfo: (id) sender;


@end
