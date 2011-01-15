//
//  WPADelegate.m
//  Nudge
//
//  Created by Charles on 11/17/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "WPADelegate.h"
#import "Context.h"
#import "Module.h"
#import "Note.h"
#import "Growl.h"
#import "IconsFile.h"
#import "TaskInfo.h"

@implementation WPADelegate
@synthesize window;
@synthesize prefsWindow;
@synthesize statsWindow;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;

-(void) start 
{
	// check for trouble
	Context *ctx = [Context sharedContext];
	if ([ctx.instancesMap count] == 0){
		NSLog(@"no modules found");
	}
	
	// start listening for pause commands
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(handleNotification:) name:@"org.ottoject.nudge.Concentrate" object:nil];

	// fire up all the alerting modules

	[self setState: ctx.startingState];
	
	[self performSelector:@selector(growlLoop)];
	ctx.running = YES;
	
	NSDictionary *modules = [[Context sharedContext] instancesMap];
	<Module> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled){
			module.handler = self;
			[module start];
		}
	}
	
	
}

-(void) setState: (int) state
{
	switch (state) {
		case STATE_AWAY:
			[self goAway];
			break;
		case STATE_PUTZING:
			[self putter];
			break;
		case STATE_THINKING:
			[Context sharedContext].thinkTime = 0;
		case STATE_THINKTIME:
			[self think: [Context sharedContext].thinkTime];
			break;
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	Context *ctx = [Context sharedContext];

	NSLog(@"app launched");
	[GrowlApplicationBridge setGrowlDelegate:self];
	if (ctx.startOnLoad){
		[self start];
	}
	[window setTitle:__APPNAME__];
}


-(void) stop 
{
	Context	*ctx = [Context sharedContext];
	// shut up!
	while ([ctx.alertQ count] > 0) {
		[ctx.alertQ removeObjectAtIndex:0];
	} 
	NSDictionary *modules = [[Context sharedContext] instancesMap];
	NSString *modName;
	<Module> module = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.started == YES){
			[module stop];
		}
	}
	[Context sharedContext].running = NO;
	
}


-(void) think: (int) minutes
{
	Context *ctx = [Context sharedContext];
	// first dump everything not urgent into save queue...
	NSMutableArray	*replaceQ = [[NSMutableArray alloc] initWithCapacity:10];

	while ([ctx.alertQ count] > 0) {
		Note *moveAlert = [ctx.alertQ objectAtIndex:0];
		if (moveAlert.urgent) {
			[replaceQ addObject: moveAlert];
		} else {
			[ctx.savedQ addObject:moveAlert];
		}
		[ctx.alertQ removeObjectAtIndex:0];
	} 
	ctx.alertQ = replaceQ;
	NSDictionary *modules = [[Context sharedContext] instancesMap];
	<Module> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module.handler = self;
		module = [modules objectForKey:modName];
		if (module.enabled){
			[module think];
		}
	}
	if (minutes > 0){
		ctx.thinkTimer = [NSTimer scheduledTimerWithTimeInterval:minutes * 60 
														  target:self 
														selector:@selector(alarm) 
														userInfo:nil repeats:NO];
	}
}

- (void) alarm
{
	NSSound *systemSound = [NSSound soundNamed:[Context sharedContext].alertName];
	[systemSound play];
	NSNotification *notice = [NSNotification notificationWithName:@"org.ottoject.alarm" object:nil];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotification:notice];
	[self putter];
}

-(void) putter
{
	
	Context *ctx = [Context sharedContext];
	[ctx.thinkTimer invalidate];
	ctx.thinkTimer = nil;
	
	// first dump everything saved into the queue...
	while ([ctx.savedQ count] > 0) {
		Note *moveAlert = [ctx.savedQ objectAtIndex:0];
		[ctx.alertQ insertObject: moveAlert atIndex:0];
		[ctx.savedQ removeObjectAtIndex:0];
	} 
	NSDictionary *modules = [[Context sharedContext] instancesMap];
	<Module> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled){
			module.handler = self;
			[module putter];
		}
	}
	
}

- (void) goAway 
{ 
	Context *ctx = [Context sharedContext];
	// first dump everything (EVERYTHING) into save queue...
	
	while ([ctx.alertQ count] > 0) {
		Note *moveAlert = [ctx.alertQ objectAtIndex:0];
		[ctx.savedQ addObject: moveAlert];
		[ctx.alertQ removeObjectAtIndex:0];
	} 

	NSDictionary *modules = [[Context sharedContext] instancesMap];
	<Module> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled){
			module.handler = self;
			[module goAway];
		}
	}
}

- (void) back
{
	// mr. user has returned from the bathroom/meeting/snack/whacking off whatever
	// fire back up where we left off
}
-(void) growlLoop 
{
	NSMutableArray *q = [[Context sharedContext]alertQ];
//	NSLogDebug(@"Checking Q...");
	if ([q count] > 0){
		[self growlAlert:[q objectAtIndex:0]];
		[q removeObjectAtIndex:0];
	}
	int interval = [Context sharedContext].growlInterval;
	[self performSelector:@selector(growlLoop) withObject:nil afterDelay:interval];
}

-(void) growlAlert: (Note*) alert
{
	NSLog(@"showing alert %@", alert.message);
	<Module> sender = [[[Context sharedContext] instancesMap] objectForKey:alert.moduleName];
	

	[GrowlApplicationBridge
	 notifyWithTitle: alert.title == nil ? sender.notificationTitle : alert.title
	 description:alert.message
	 notificationName:sender.notificationName
	 iconData:[[Context sharedContext]iconForModule:sender]
	 priority:0
	 isSticky:alert.sticky
	 clickContext:alert.params];
}

- (void) growlNotificationWasClicked:(id)ctx 
{
	<Module> callMod = [[Context sharedContext].instancesMap objectForKey:[ctx objectForKey: @"module"]];
	
	[callMod handleClick:ctx];
		
}

-(void) saveAlert: (Note*) alert
{
	Context *ctx = [Context sharedContext];
	if ([ctx.savedQ containsObject: alert]){
		NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[ctx.savedQ addObject:alert];
}

-(void) queueAlert: (Note*) alert
{
	Context *ctx = [Context sharedContext];
	if ([ctx.alertQ containsObject: alert]){
		NSLog(@"skipping duplicate alert %@", alert.message);
		return; 
	}
	[[Context sharedContext].alertQ addObject:alert];
}

-(void) handleError: (Note*) error
{
	<Module> sender = [[[Context sharedContext] instancesMap] objectForKey:error.moduleName];
	
	[GrowlApplicationBridge
	 notifyWithTitle:@"Error!"
	 description:error.message
	 notificationName:@"Error Alert"
	 iconData:[[Context sharedContext]iconForModule:sender]
	 priority:0
	 isSticky:YES
	 clickContext:nil];
}

-(void) handleAlert:(Note*) alert 
{
	NSLog(@"received %@",alert.message);
	Context *ctx = [Context sharedContext];
	if (ctx.startingState == STATE_PUTZING) {
		[self queueAlert:alert];
	}
	else {
		if ([alert urgent] == YES ){
			[self queueAlert:alert];
		} else {
			[self saveAlert: alert];
			NSLog(@"saved %@",alert.message);
	}
	}

}

-(void)handleNotification:(NSNotification*) notification
{	
	NSDictionary *dict = [notification userInfo];
	NSNumber *minStr =  [dict objectForKey:@"time"];
	NSNumber *state =  [dict objectForKey:@"state"];
	[Context sharedContext].thinkTime = [minStr intValue];
	[self setState:[state intValue]]; 
}



-(void) refreshTasks
{
	NSDictionary *modules = [[Context sharedContext] instancesMap];
	<Module> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled){
			[module refreshTasks];
		}
	}
}

-(NSArray*) getAllTasks
{
	NSMutableDictionary *gather = [NSMutableDictionary new];
	NSDictionary *modules = [[Context sharedContext] instancesMap];
	<Module> module = nil;
	NSString *modName = nil;
	for (modName in modules){
		module = [modules objectForKey:modName];
		if (module.enabled){
			NSArray *items = module.trackingItems;
			if (items){
				for(NSString *item in items){
					TaskInfo *info = [[TaskInfo alloc] initWithName:item 
					source : module 
					project:[module projectForTask:item]];
					TaskInfo *fo = [gather objectForKey:info.name];
					if (fo){
						fo.description = [NSString stringWithFormat:@"%@ [%@]",fo.name,[fo.source description] ];
						info.description = [NSString stringWithFormat:@"%@ [%@]",info.name,[info.source description] ];
					}
					[gather setObject:info forKey:info.description];
				}
			}
		}
	}
	return [gather allValues];
}

- (IBAction) clickPreferences: (id) sender
{
    if (prefsWindow == nil) {
        prefsWindow = [[PreferencesWindow alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
	
	[prefsWindow showWindow: self];
	[prefsWindow.window makeKeyAndOrderFront:self];
	[[prefsWindow window] orderFrontRegardless];

}

-(IBAction) clickTasksInfo: (id) sender
{
	if (statsWindow == nil)
		statsWindow = [[StatsWindow alloc] initWithWindowNibName:@"StatsWindow"];
	
	[statsWindow showWindow:self];
	[statsWindow.window makeKeyAndOrderFront:self];
	[[statsWindow window] orderFrontRegardless];
}


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
		case STATE_THINKTIME:
		case STATE_THINKING:
			return @"Work";
			break;
		case STATE_AWAY:
			return @"Away";
			break;
		case STATE_PUTZING:
			return @"Free";
			break;
		case STATE_OFF:
		default:
			return nil;
	}
}

- (void) removeStore: (id) sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" 
									 defaultButton:@"No" alternateButton:@"Yes" 
									   otherButton:nil 
						 informativeTextWithFormat:@"To delete this data %@ must quit. Click yes to quit and delete the data",__APPNAME__];
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

- (void) newRecord: (int) state
{
	Context *ctx = [Context sharedContext];
	if (ctx.currentActivity != nil){
		NSDate *start = [ctx.currentActivity valueForKey:@"startTime"];
		NSDate *now = [NSDate date];
		NSTimeInterval interval = [now timeIntervalSinceDate:start];
		[ctx.currentActivity setValue:[NSNumber numberWithInt:interval] forKey:@"interval"];
		[ctx.currentActivity setValue: now forKey:@"endTime"];
		NSLog(@"Done with %@% interval: %f", [self dumpMObj:ctx.currentActivity], interval);
	} else {
		NSLog(@"No Current Activity");
	}
	// new work record
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSManagedObject *task = nil;
	NSManagedObject *source = nil;
	NSString *newTask = ctx.currentTask == nil ? @"[No Task]" : ctx.currentTask.name;		
	NSString *newSource = ctx.currentTask == nil || ctx.currentTask.source == nil ? @"[Adhoc]" : [ctx.currentTask.source description];		

	if (state == STATE_THINKING || state == STATE_THINKTIME){
		source = [self findSource: newSource inContext: moc];
		if (source == nil){
			source = [NSEntityDescription
					insertNewObjectForEntityForName:@"Source"
					inManagedObjectContext:moc];
			[source setValue:[NSDate date] forKey: @"createTime"];
			[source setValue:[newSource description] forKey:@"name"];
		}
		
		task = [self findTask: newTask inContext: moc];
		if (task == nil){
			task = [NSEntityDescription
					insertNewObjectForEntityForName:@"Task"
					inManagedObjectContext:moc];
			[task setValue:[NSDate date] forKey: @"createTime"];
			[task setValue:newTask forKey: @"name"];
			if (source != nil) {
				[task setValue:source forKey:@"source"];
			}
			
		}
	}
	NSString *entityName = [self entityNameForState:state];
	if (entityName != nil) {
		NSManagedObject *newActivity = [NSEntityDescription
										insertNewObjectForEntityForName:entityName
										inManagedObjectContext:moc];
		if ([self hasTask:newActivity] && task != nil){
			[newActivity setValue:task forKey:@"task"];
		}
		[newActivity setValue: [NSDate date] forKey:@"startTime"];	
		[newActivity setValue: @"" forKey:@"notes"];
		ctx.currentActivity = newActivity;
		NSLog(@"Starting %@", [self dumpMObj:ctx.currentActivity]);
	}
	else {
		ctx.currentActivity = nil;
	}
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
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
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
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    if (!managedObjectContext) return NSTerminateNow;
	
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }
	
    if (![managedObjectContext hasChanges]) return NSTerminateNow;
	
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
		
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
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
		
    }
	
    return NSTerminateNow;
}

-(IBAction)handleNewMainWindowMenu:(NSMenuItem *)sender
{
	[window makeKeyAndOrderFront:self];
	[window orderFrontRegardless];
}

@end
