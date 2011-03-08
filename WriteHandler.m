//
//  IOHandler.m
//  WorkPlayAway
//
//  Created by Charles on 3/3/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "WriteHandler.h"
#import "State.h"
#import "Context.h"

@implementation WriteHandler
@synthesize stopMe;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize currentSummary;
@synthesize error;
@synthesize reply;

+ (void) initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:600.0], @"diskFlushInterval", nil];
    [defaults registerDefaults:appDefaults];
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
	
	error = nil;
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
	
	error = nil;
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
	
	error = nil;
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
	NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" 
									 defaultButton:@"No" alternateButton:@"Yes" 
									   otherButton:nil 
						 informativeTextWithFormat:@"To delete this data %@ must quit. Click yes to quit and delete the data",__APPNAME__];
	[alert runModal];   
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
	error = nil;
	
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

- (BOOL) hasTask: (NSManagedObject*) mobj
{
	NSEntityDescription *desc = [mobj entity];
	NSDictionary *dict = [desc propertiesByName];
	BOOL answer = [dict objectForKey:@"task"] != nil;
	return answer;
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


- (NSManagedObject*) findSummaryForDate:(NSDate *)dateIn
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"DailySummary"
				inManagedObjectContext:[self managedObjectContext]];
	if (entity) {
		[request setEntity:entity];
		
		NSPredicate *predicate =
		[NSPredicate predicateWithFormat:@"recordDate == %@", dateIn];
		[request setPredicate:predicate];
		
		error = nil;
		NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
		if (array != nil && [array count] == 1) {
			return [array objectAtIndex:0];
		}
	}
	return nil;
}

- (void) findSummaryForDate: (NSDate*) dateIn work: (NSTimeInterval*) workInt free: (NSTimeInterval*) freeInt
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
}

- (void) saveSummaryForDate: (NSNotification*) msg
//(NSDate*) date goal: (int) goalTime work: (int) workTime free: (int) freeTime
{
	NSDictionary *d = msg.userInfo;
	NSDate *inDate = (NSDate*)[d objectForKey:@"date"];
	int goalTime = ((NSNumber*)[d objectForKey:@"goal"]).intValue;
	int workTime = ((NSNumber*)[d objectForKey:@"work"]).intValue;
	int freeTime = ((NSNumber*)[d objectForKey:@"free"]).intValue;
	// new work record
	NSManagedObjectContext *moc = [self managedObjectContext];
	BOOL needsNewRec = NO;
	// if the currentSummary does not exist we are starting up so look for one for today (because we restarted)
	// and if there is nothing for today then create a new one
	if (currentSummary == nil){
		currentSummary = [self findSummaryForDate: inDate];
		if (!currentSummary){
			needsNewRec = YES;
		}
	}
	// or we are here and there is already a summary -- so check to see if the date has changed
	else {
		NSDate *recDate = (NSDate*)[currentSummary valueForKey:@"recordDate"];
		NSTimeInterval int1 = [recDate timeIntervalSince1970];
		NSTimeInterval int2 = [inDate timeIntervalSince1970];
		if ((NSUInteger)int1 != (NSUInteger)int2){
			needsNewRec = YES;
		}
	}
	if (needsNewRec){
		NSLog(@"writing new summary for %@", inDate);
		
		currentSummary = [NSEntityDescription
						  insertNewObjectForEntityForName:@"DailySummary"
						  inManagedObjectContext:moc];
		[currentSummary setValue: inDate forKey: @"recordDate"];
		
	}
	
	[currentSummary setValue:[NSNumber numberWithInt:workTime] forKey:@"timeWork"];
	[currentSummary setValue:[NSNumber numberWithInt:freeTime] forKey:@"timeFree"];
	[currentSummary setValue:[NSNumber numberWithInt:goalTime] forKey:@"timeGoal"];
	
}

- (void) newRecord:(NSNotification*) msg
{

	NSDictionary *dict = [msg userInfo];
	Context *ctx = [Context sharedContext];
	if (ctx.currentActivity != nil){
		NSDate *start = [ctx.currentActivity valueForKey:@"startTime"];
		NSDate *now = [dict objectForKey:@"date"];
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
	WPAStateType state = ((NSNumber*)[dict objectForKey:@"state"]).intValue;
	if (state == WPASTATE_THINKING || state == WPASTATE_THINKTIME){
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
	
     error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (void) doWrapUp: (NSObject*) ignore	
{
	NSLog(@"doWrapUp");
    error = nil;
	if (!managedObjectContext) {
		NSLog(@"no managedObjectContext");
		reply = NSTerminateNow;
		return;
	}
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        reply = NSTerminateCancel;
		return;
    }
	
    if (![managedObjectContext hasChanges]){
		NSLog(@"no managedObjectContext changes");
		reply = NSTerminateNow;
		return;
	}
	NSLog(@"starting save...");
    if (![managedObjectContext save:&error]) {
		NSLog(@"save error: %@",error);
		reply = NSTerminateCancel;
		return;
	}
 	NSLog(@"....saved");
   reply = NSTerminateNow;
}

-(void) doFlush: (NSTimer*) timer
{
	NSError *err = nil;
	[[self managedObjectContext] save: &err];
	if (err){
		[[NSApplication sharedApplication] presentError:err];
	}
}

+ (void) sendNewRecord: (WPAStateType) state
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"newrecord" 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																[NSDate date],@"date",
																[NSNumber numberWithInt:state], @"state",
																nil]]; 
}

+ (void) sendSummaryForDate: (NSDate*) date goal: (int) goalTime work: (int) workTime free: (int) freeTime

{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"summary" 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																date,@"date",
																[NSNumber numberWithInt:workTime], @"work",
																[NSNumber numberWithInt:freeTime], @"free",
																[NSNumber numberWithInt:goalTime], @"goal",
																nil]]; 
}

- (void) ioLoop: (NSObject*) param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	// Create and schedule the first timer.
	NSTimeInterval saveInt = [[NSUserDefaults standardUserDefaults] doubleForKey:@"diskFlushInterval"];
	NSDate* futureDate = [NSDate dateWithTimeIntervalSinceNow:saveInt];
	NSTimer* myTimer = [[NSTimer alloc] initWithFireDate:futureDate
												interval:saveInt
												  target:self
												selector:@selector(doFlush:)
												userInfo:nil
												 repeats:YES];
	[runLoop addTimer:myTimer forMode:NSDefaultRunLoopMode];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(newRecord:) 
												 name:@"newrecord" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(saveSummaryForDate:) 
												 name:@"summary" 
											   object:nil];
	
//	while (!stopMe && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	double resolution = 300.0;
	BOOL isRunning;
	do {
		// run the loop!
		NSLog(@"in run loop");
		NSDate* theNextDate = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
		isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:theNextDate]; 
		// occasionally re-create the autorelease pool whilst program is running
		[pool drain];
		pool = [[NSAutoreleasePool alloc] init];            
	} while(isRunning==YES && stopMe==NO);
	
	[pool drain];
}
@end

