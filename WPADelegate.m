//
//  WPADelegate.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/17/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "WPADelegate.h"
#import "Context.h"
#import "Instance.h"
#import "WPAAlert.h"
#import "Growl.h"
#import "IconsFile.h"
#import "State.h"
#import "WriteHandler.h"

#define APPNAMESTR __APPNAME__
@implementation WPADelegate
@synthesize window;
@synthesize prefsWindow;
@synthesize statsWindow;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize currentSummary;
@synthesize ioThread;
@synthesize ioHandler;
@synthesize wpam;
@synthesize icDaemon;
@synthesize amDaemon;

+ (void) initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:600.0], @"diskFlushInterval", nil];
    [defaults registerDefaults:appDefaults];
}

- (NSError*)application:(NSApplication*)application
       willPresentError:(NSError*)error
{
    if (error)
    {
//        NSDictionary* userInfo = [error userInfo];
        //NSLog (@"encountered the following error: %@", userInfo);
        Debugger();
    }
    
    return error;
}

- (void) saveData: (NSTimer*) timer
{

	[NSThread detachNewThreadSelector: @selector(doSaveThread:)
							 toTarget:self
						   withObject:nil];
	
	NSTimeInterval saveInt = [[NSUserDefaults standardUserDefaults] doubleForKey:@"diskFlushInterval"];
	[NSTimer scheduledTimerWithTimeInterval:saveInt target:self selector:@selector(saveData:) userInfo:nil repeats:NO ];
}

- (NSTask*) startDaemon: (NSString*) name 
{
	NSString *supportDir = [self applicationSupportDirectory];
	NSString *monitorPath = [NSString stringWithFormat:@"%@/Plugins/%@",supportDir, name];
	NSLog(@"monitorPath = %@", monitorPath);
	NSTask *task = [NSTask launchedTaskWithLaunchPath:monitorPath arguments:[NSArray new]];
	if (!task){
		NSLog(@"error launching %@", name);
	}
	return task;
}

- (void) startDaemons
{
	amDaemon = [self startDaemon:@"AppleMailDaemon"];
	icDaemon = [self startDaemon:@"ICalDaemon"];
		
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	//WPAMainController *wpam = (WPAMainController*)[window delegate];
	//NSLog(@"app launched");
	[self startDaemons];
	if ([[NSUserDefaults standardUserDefaults]boolForKey:@"startOnLoad"]){
		[wpam clickStart:self];
	}
	[window setTitle: APPNAMESTR];
	ioHandler = [WriteHandler new];
	
	ioThread = [[NSThread alloc] initWithTarget:ioHandler selector:@selector(ioLoop:) object:nil];
	[ioThread start];
}

//- (WPAMainController*) mainCtrl
//{
//	return (WPAMainController*)[window delegate];
//
//}


/*****************************************************************************************
 Support for saving data follows:
*****************************************************************************************/

/**
 Returns the support directory for the application, used to store the Core Data
 store file.  This code uses a directory named "BAndD" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {
	 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:__APPNAME__];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (double) countEntity: (NSString*) name inContext: (NSManagedObjectContext*) moc
{
	double cum = 0.0;
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:name
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	for (NSManagedObject *obj in array)
	{
		NSNumber *num = [obj valueForKey: @"interval"];
		cum += [num doubleValue];
	}
	return cum;
}


- (NSManagedObject*) findSource: (NSString*) name inContext: (NSManagedObjectContext*) moc
{
	if (name == nil)
		return nil;
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Source"
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
	NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"self == %@", name];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if (array != nil && [array count] == 1) {
		return (NSManagedObject*)[array objectAtIndex:0];
	}
	else {
		return nil;
	}
}

- (NSManagedObject*) findTask: (NSString*) name inContext: (NSManagedObjectContext*) moc
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Task"
				inManagedObjectContext:moc];
	[request setEntity:entity];
	
	NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"self == %@", name];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if (array != nil && [array count] == 1) {
		return (NSManagedObject*)[array objectAtIndex:0];
	}
	else {
		return nil;
	}
}

-(NSString*) entityNameForState:(int) state
{
	switch (state) {
		case WPASTATE_THINKTIME:
		case WPASTATE_THINKING:
			return @"Work";
			break;
		case WPASTATE_AWAY:
			return @"Away";
			break;
		case WPASTATE_FREE:
			return @"Free";
			break;
		case WPASTATE_OFF:
		default:
			return nil;
	}
}

- (void) removeStore: (id) sender
{
    NSString *appName = __APPNAME__;
	NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" 
									 defaultButton:@"No" alternateButton:@"Yes" 
									   otherButton:nil 
						 informativeTextWithFormat:@"To delete this data %@ must quit. Click yes to quit and delete the data",appName];
	[alert runModal];   
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
	[fileManager removeItemAtURL:url error:&error];
//	NSArray *stores = [persistentStoreCoordinator persistentStores];
////	for (NSPersistentStore *store in stores){
//		NSError *error = [NSError new];
//		[persistentStoreCoordinator removePersistentStore:store error: &error];
//	}
	[self.managedObjectContext reset];
	self.managedObjectContext = nil;
	self.persistentStoreCoordinator = nil;
	self.managedObjectModel = nil;
}

- (NSString*) dumpMObj: (NSManagedObject*) obj
{
	NSString *eName = [[obj entity] name];
	NSString *tName = @"No Task";
	if ([self hasTask:obj]){
		NSManagedObject	*task = [obj valueForKey:@"task"];
		if (task)
			tName = [task valueForKey:@"name"];
	}
	return [NSString stringWithFormat:@"%@ [%@]",eName, tName];
}

- (BOOL) hasTask: (NSManagedObject*) mobj
{
	NSEntityDescription *desc = [mobj entity];
	NSDictionary *dict = [desc propertiesByName];
	BOOL answer = [dict objectForKey:@"task"] != nil;
	return answer;
}

- (NSManagedObject*) findSummaryForDate:(NSDate *)dateIn
{
    //NSLog(@"findingSummary for Date: %f",[dateIn timeIntervalSince1970]);
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"DailySummary"
				inManagedObjectContext:[self managedObjectContext]];
	if (entity) {
		[request setEntity:entity];
		
		NSPredicate *predicate =
		[NSPredicate predicateWithFormat:@"recordDate == %@", dateIn];
		[request setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
		if (array != nil && [array count] == 1) {
			return [array objectAtIndex:0];
		}
	}
	return nil;
}

- (BOOL) findSummaryForDate: (NSDate*) dateIn work: (NSTimeInterval*) workInt free: (NSTimeInterval*) freeInt
{
	NSTimeInterval retWork = 0.0;
	NSTimeInterval retFree = 0.0;

	NSManagedObject *mob = [self findSummaryForDate:dateIn];
	if (mob){
		NSNumber *temp = [mob valueForKey:@"timeWork"];
		retWork = [temp doubleValue];
		temp = [mob valueForKey:@"timeFree"];
		retFree = [temp doubleValue];
	}
	
	*workInt = retWork;
	*freeInt = retFree;
    return (mob != nil);
}

- (void) saveSummaryForDate: (NSDate*) date goal: (int) goalTime work: (int) workTime free: (int) freeTime
{
    //NSLog(@"savingSummary for Date: %f",[date timeIntervalSince1970]);

	// new work record
	NSManagedObjectContext *moc = [self managedObjectContext];
	BOOL needsNewRec = NO;
	// if the currentSummary does not exist we are starting up so look for one for today (because we restarted)
	// and if there is nothing for today then create a new one
	if (currentSummary == nil){
		currentSummary = [self findSummaryForDate: date];
		if (!currentSummary){
			needsNewRec = YES;
		}
	}
	// or we are here and there is already a summary -- so check to see if the date has changed
	else {
		NSDate *recDate = (NSDate*)[currentSummary valueForKey:@"recordDate"];
		if (![recDate isEqualToDate:date]){
			needsNewRec = YES;
		}
	}
	if (needsNewRec){
	
		currentSummary = [NSEntityDescription
							insertNewObjectForEntityForName:@"DailySummary"
							inManagedObjectContext:moc];
		[currentSummary setValue: date forKey: @"recordDate"];
		
	}

	[currentSummary setValue:[NSNumber numberWithInt:workTime] forKey:@"timeWork"];
	[currentSummary setValue:[NSNumber numberWithInt:freeTime] forKey:@"timeFree"];
	[currentSummary setValue:[NSNumber numberWithInt:goalTime] forKey:@"timeGoal"];

}

/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The directory for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        //NSLog(@"%@:%@ No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            //NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    
	
    return persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */

- (IBAction) saveAction:(id)sender {
	
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        //NSLog(@"%@:%@ unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply) handleSaveError: (NSError*) error application: (NSApplication *)sender
{
	
	// This error handling simply presents error information in a panel with an 
	// "Ok" button, which does not include any attempt at error recovery (meaning, 
	// attempting to fix the error.)  As a result, this implementation will 
	// present the information to the user and then follow up with a panel asking 
	// if the user wishes to "Quit Anyway", without saving the changes.
	
	// Typically, this process should be altered to include application-specific 
	// recovery steps.  
	
	BOOL result = [sender presentError:error];
	if (result) return NSTerminateCancel;
	
	NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
	NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
	NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
	NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:question];
	[alert setInformativeText:info];
	[alert addButtonWithTitle:quitButton];
	[alert addButtonWithTitle:cancelButton];
	
	NSInteger answer = [alert runModal];
	[alert release];
	alert = nil;
	
	if (answer == NSAlertAlternateReturn) 
		return NSTerminateCancel;
	return NSTerminateNow;
}

/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	//NSLog(@"applicationShouldTerminate");
	//WPAMainController *wpam = (WPAMainController*)[window delegate];
	[wpam changeState:WPASTATE_OFF];
	

    if (managedObjectContext && ![managedObjectContext commitEditing]) {
        //NSLog(@"%@:%@ unable to commit editing to terminate", [self class], _cmd);
		return NSTerminateCancel;
    }

	if ([managedObjectContext hasChanges]){
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			return [self handleSaveError:error application:sender];
		}
	}
	//NSLog(@"calling doWrapUp...");
	[ioHandler performSelector:@selector(doWrapUp:) onThread:ioThread withObject:nil waitUntilDone:YES];
	if (ioHandler.error){
		return [self handleSaveError:ioHandler.error application:sender];
	}
	if (icDaemon){
		[icDaemon terminate];
	}
	if (amDaemon){
		[amDaemon terminate];
	}
    return ioHandler.reply;
}


-(IBAction)handleNewMainWindowMenu:(NSMenuItem *)sender
{
	[window makeKeyAndOrderFront:self];
}

-(void) doSaveThread: (NSObject*) param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *err = nil;
	[[self managedObjectContext] save: &err];
	if (err){
		[[NSApplication sharedApplication] presentError:err];
	}
	[pool drain];	
}

@end
