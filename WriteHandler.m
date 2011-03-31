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
#import "WPADelegate.h"

@implementation WriteHandler
@synthesize stopMe;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize currentSummary;
@synthesize error;
@synthesize reply;
@synthesize activities, activityDate;
@synthesize gregorianCal;
@synthesize summary;

+ (void) initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:600.0], @"diskFlushInterval", nil];
    [defaults registerDefaults:appDefaults];
}

- (id) initWithCoordinator: (NSPersistentStoreCoordinator*) coordinator
{
    persistentStoreCoordinator = coordinator;
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
    [NSPredicate predicateWithFormat:@"name == %@", name];
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

- (NSManagedObject*) findActivityForDate: (NSDate*) dateIn project: (NSString*) proj task: (NSString*) taskName source: (NSString*) src 
{
    if (activities == nil || ![activityDate isEqualToDate:dateIn]){
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"DailyActivity"
                    inManagedObjectContext:[self managedObjectContext]];
        if (entity) {
            [request setEntity:entity];
            
            NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"date == %@ ", dateIn];
            [request setPredicate:predicate];
            
            error = nil;
            activities = [managedObjectContext executeFetchRequest:request error:&error];
            
        }
    }
    for (NSManagedObject *act in activities){
        NSManagedObject *taskObj = [act valueForKey:@"task"];
        NSString *tName = [taskObj valueForKey:@"name"];
        if (![tName isEqualToString:taskName]){
            continue;
        }
        else {
            if (proj) {
                NSManagedObject *projObj = [taskObj valueForKey:@"project"];
                if (!projObj){
                    continue;
                }
                NSString *projName = [projObj valueForKey:@"name"];
                if (projName == nil || ![projName isEqualToString:proj])
                    continue;
            }
            if (src) {
                NSManagedObject *sourceObj = [taskObj valueForKey:@"source"];
                if (!sourceObj){
                    continue;
                }
                NSString *srcName = [sourceObj valueForKey:@"name"];
                if (srcName == nil || ![srcName isEqualToString:src])
                    continue;
            }
            
        }
        return act;
    }
	return nil;
    
}

- (void) saveTotalsForDate: (NSNotification*) msg
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
        //       NSLog(@"%@ using existing summary for %@",[NSThread currentThread], inDate);
        NSDate *recDate = (NSDate*)[currentSummary valueForKey:@"recordDate"];
		NSTimeInterval int1 = [recDate timeIntervalSince1970];
		NSTimeInterval int2 = [inDate timeIntervalSince1970];
		if ((NSUInteger)int1 != (NSUInteger)int2){
			needsNewRec = YES;
		}
	}
	if (needsNewRec){
        //		NSLog(@"%@ writing new summary for %@",[NSThread currentThread], inDate);
		
		currentSummary = [NSEntityDescription
						  insertNewObjectForEntityForName:@"DailySummary"
						  inManagedObjectContext:moc];
		[currentSummary setValue: inDate forKey: @"recordDate"];
		
	}
	
	[currentSummary setValue:[NSNumber numberWithInt:workTime] forKey:@"timeWork"];
	[currentSummary setValue:[NSNumber numberWithInt:freeTime] forKey:@"timeFree"];
	[currentSummary setValue:[NSNumber numberWithInt:goalTime] forKey:@"timeGoal"];
	
}

- (NSManagedObject*) findProjectForName: (NSString*) pName
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Project"
                inManagedObjectContext:[self managedObjectContext]];
    if (entity) {
        [request setEntity:entity];
        
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"name == %@ ", pName];
        [request setPredicate:predicate];
        
        error = nil;
        NSArray *projs = [managedObjectContext executeFetchRequest:request error:&error];
        if (projs && [projs count] > 0){
            return [projs objectAtIndex:0];
        }
    }
    return nil;
}

- (NSManagedObject*) findTask: (NSString*) taskName project:(NSString*) projectName source: (NSString*) sourceName
{
    NSArray *taskList;
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Task"
                inManagedObjectContext:[self managedObjectContext]];
    if (entity) {
        [request setEntity:entity];
        
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"name == %@ ", taskName];
        [request setPredicate:predicate];
        
        error = nil;
        taskList = [managedObjectContext executeFetchRequest:request error:&error];
        
    }
    
    for (NSManagedObject *task in taskList){
        if (projectName) {
            NSManagedObject *projObj = [task valueForKey:@"project"];
            if (!projObj){
                continue;
            }
            NSString *projName = [projObj valueForKey:@"name"];
            if (projName == nil || ![projName isEqualToString:projectName])
                continue;
        }
        
        if (sourceName) {
            NSManagedObject *sourceObj = [task valueForKey:@"source"];
            if (!sourceObj){
                continue;
            }
            NSString *srcName = [sourceObj valueForKey:@"name"];
            if (srcName == nil || ![srcName isEqualToString:sourceName]){
                continue;
            }
        }
        NSLog(@"found task %@", taskName);
        return task;
    }
    NSLog(@"no task named %@", taskName);
	return nil;
}

- (void) saveActivityForDate:(NSDate*) inDate desc: (NSString*) taskName source: (NSString*) sourceName project: (NSString*) projectName addVal: (int) increment
{
    if (!taskName){
        NSLog(@"not saving task data");
        return;
    };
    NSError *err = nil;
    NSManagedObject *projObj = nil;
    NSManagedObject *srcObj = nil;
    NSManagedObject *taskObj = nil;
    NSManagedObject *actObj = nil;
    actObj = [self findActivityForDate:inDate project:projectName task:taskName source:sourceName];
    if (actObj == nil){
        taskObj = [self findTask:taskName project:projectName source:sourceName];
        if (!taskObj) {
            
            if (projectName){
                projObj = [self findProjectForName: projectName];
                if (!projObj){
                    projObj = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Project"
                               inManagedObjectContext:managedObjectContext]; 
                    
                    [projObj setValue:projectName forKey:@"name"];
                    [projObj setValue:[NSDate date] forKey:@"createTime"];
                    [projObj validateForInsert:&err];
                    if (err){
                        NSLog(@"error: %@",err);
                    }
                    [managedObjectContext insertObject:projObj];
                    NSLog(@"created project: %@", projectName);
                }
            }
            if (sourceName){
                srcObj = [self findSource:sourceName inContext: managedObjectContext];
                if (!srcObj){
                    srcObj = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Source"
                              inManagedObjectContext:managedObjectContext];   
                    [srcObj setValue:sourceName forKey:@"name"];
                    [srcObj setValue:[NSDate date] forKey:@"createTime"];
                    [srcObj setValue:@"Test" forKey:@"type"];
                    [srcObj validateForInsert:&err];
                    if (err){
                        NSLog(@"error: %@",err);
                    }
                    [managedObjectContext insertObject:srcObj];

                    NSLog(@"created source: %@", sourceName);
                }
            }
            taskObj = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Task"
                       inManagedObjectContext:managedObjectContext];   
            [taskObj setValue:taskName forKey:@"name"];
            [taskObj setValue:inDate forKey:@"createTime"];  
            if (srcObj){
                [taskObj setValue:srcObj forKey:@"source"];
            }
            if (projObj){
                [taskObj setValue:projObj forKey:@"project"];
            }
            [taskObj validateForInsert:&err];
            if (err){
                NSLog(@"error: %@",err);
            } 
            NSLog(@"created task: %@", taskName);
            [managedObjectContext insertObject:taskObj];
       
        }
        actObj = [NSEntityDescription
                  insertNewObjectForEntityForName:@"DailyActivity"
                  inManagedObjectContext:managedObjectContext]; 
        [actObj setValue: [NSNumber numberWithInt:increment] forKey:@"total"];
        [actObj setValue: inDate forKey:@"date"];
        [actObj setValue: taskObj forKey:@"task"];
        
        if (!gregorianCal){
            
            gregorianCal = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSGregorianCalendar];
        }
        NSDateComponents *dateParts =
        [gregorianCal components
         :NSWeekdayCalendarUnit|NSDayCalendarUnit| NSMonthCalendarUnit| NSYearCalendarUnit fromDate:inDate];
        [actObj setValue:[NSNumber numberWithInt:dateParts.day] forKey: @"day"];
        [actObj setValue:[NSNumber numberWithInt:dateParts.month] forKey: @"month"];
        [actObj setValue:[NSNumber numberWithInt:dateParts.year] forKey: @"year"];
        [actObj setValue:[NSNumber numberWithInt:dateParts.week] forKey: @"week"];
        [actObj setValue:[NSNumber numberWithInt:dateParts.weekday] forKey: @"weekDay"];
        [actObj validateForInsert:&err];
        if (err){
            NSLog(@"error: %@",err);
            NSLog(@"created activity for task %@ [%@]", taskName, inDate);
        }  
        [managedObjectContext insertObject:actObj];

    }
    NSNumber *val = [actObj valueForKey:@"total"];
    NSUInteger oldVal = val ? val.intValue : 0;
    NSNumber *newVal =[NSNumber numberWithInt:increment + oldVal];
    [actObj setValue:newVal forKey:@"total"];
    [managedObjectContext refreshObject:actObj mergeChanges:YES];
    NSLog(@"updated activity to %d for task %@ [%@]",increment,	 taskName, inDate);
    
    
//    if (![managedObjectContext commitEditing]) {
//        NSLog(@"%@: unable to commit editing before saving", [self class]);
//    }
//    [managedObjectContext save:&err];
//    if (err){
//        NSLog(@"error: %@",err);
//    }
}

- (void) saveActivityForDate:(NSNotification*) msg
{
    //		date,@"date",
    //  taskInfo.project, @"project",
    //   taskInfo.name, @"activity",
    //   taskInfo.source.name,  @"source",
    // [NSNumber numberWithInt:incr], @"increment",
	NSDictionary *d = msg.userInfo;
	NSDate *inDate = (NSDate*)[d objectForKey:@"date"];
	int increment = ((NSNumber*)[d objectForKey:@"increment"]).intValue;
    TaskInfo *info = (TaskInfo*)[d objectForKey:@"taskInfo"];

    [self saveActivityForDate:inDate desc: info.name source:info.source.name project:info.project addVal:increment];
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The directory for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    persistentStoreCoordinator =
    [((WPADelegate*)[[NSApplication sharedApplication] delegate]) persistentStoreCoordinator];
    return persistentStoreCoordinator;
}
//    NSManagedObjectModel *mom = [self managedObjectModel];
//    if (!mom) {
//        NSAssert(NO, @"Managed object model is nil");
//        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
//        return nil;
//    }
//	
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
//    
//    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
//		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
//            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
//            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
//            return nil;
//		}
//    }
//    
//    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
//    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
//    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
//												  configuration:nil 
//															URL:url 
//														options:nil 
//														  error:&error]){
//        [[NSApplication sharedApplication] presentError:error];
//        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
//        return nil;
//    }    
//	
//    return persistentStoreCoordinator;

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
	NSLog(@"doing save");
    error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@ unable to commit editing before saving", [self class]);
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

- (void) doFlush
{
	NSError *err = nil;
	[[self managedObjectContext] save: &err];
	if (err){
		[[NSApplication sharedApplication] presentError:err];
	}
}

-(void) doFlush: (NSTimer*) timer
{
	[self doFlush];
}


+ (void) sendTotalsForDate: (NSDate*) date goal: (int) goalTime work: (int) workTime free: (int) freeTime
{
    WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication] delegate];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"totals" 
														object: del.ioHandler
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																date,@"date",
																[NSNumber numberWithInt:workTime], @"work",
																[NSNumber numberWithInt:freeTime], @"free",
																[NSNumber numberWithInt:goalTime], @"goal",
																nil]]; 
}

+ (void) sendActivity: (NSDate*)date
             activity:(TaskInfo*)taskInfo
            increment:(int) incr
{
    WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication] delegate];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"activity" 
														object: del.ioHandler
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																date,@"date",
																taskInfo, @"taskInfo",
                                
																[NSNumber numberWithInt:incr], @"increment",
																nil]]; 
}

- (void) saveSummary: (SummaryRecord*) rec
{
	if (!summary){
        summary = [NSEntityDescription insertNewObjectForEntityForName: @"AllTimeData"
                                                inManagedObjectContext: [self managedObjectContext]]; 
    }
    [summary setValue:rec.dateStart forKey:@"dateStart"];
    [summary setValue:rec.timeWorked forKey:@"timeWorked"];
    
    [summary setValue:rec.timeGoal forKey:@"timeGoal"];
    [summary setValue:rec.timeTotal forKey:@"timeTotal"];
    [summary setValue:rec.daysGoalAchieved forKey:@"daysGoalAchieved"];
    
    [summary setValue:rec.daysTotal forKey:@"daysTotal"];
    [summary setValue:rec.daysWorked forKey:@"daysWorked"];
    [summary setValue:rec.lastGoalAchieved forKey:@"lastGoalAchieved"];
    
    [summary setValue:rec.lastWorked forKey:@"lastWorked"];
    [summary setValue:rec.lastDay forKey:@"lastDay"];
    [summary setValue:rec.dateWrite forKey:@"dateWrite"];
}

- (void) saveSummaryRecord: (NSNotification*) msg
{
	NSDictionary *d = msg.userInfo;
	SummaryRecord *rec = (SummaryRecord*)[d objectForKey:@"record"];
    [self saveSummary:rec];
}


+ (void) sendSummary: (SummaryRecord*) rec
{
    WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication] delegate];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"summary" 
														object: del.ioHandler
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																rec,@"record",
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
											 selector:@selector(saveTotalsForDate:) 
												 name:@"totals" 
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(saveActivityForDate:) 
												 name:@"activity" 
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(saveSummaryRecord:) 
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

- (SummaryRecord*) getSummaryRecord
{
    SummaryRecord *rec = [SummaryRecord new];
    // if summary not loaded then try to read it
    if (!summary){
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"AllTimeData"
                    inManagedObjectContext:[self managedObjectContext]];
        [request setEntity:entity];
        
        NSArray *array = [[self managedObjectContext] executeFetchRequest:request error:&error];
        if (array != nil && [array count] == 1) {
            summary = (NSManagedObject*)[array objectAtIndex:0];
            rec = [rec initWithEntity:summary];
        }
    }
    // couldn't read summary so create empty summary and save it
	if (!summary){
        [self saveSummary: rec];
	}
    
    return rec;
}



@end

