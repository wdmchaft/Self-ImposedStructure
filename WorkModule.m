//
//  WorkModule.m
//  Self-Imposed Structure
//
//  Created by Charles on 2/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "WorkModule.h"
#import "State.h"
#import "ChooseApp.h"
#import "Queues.h"

@interface WatchApp : NSObject
{
	NSString *idString;
	NSString *nameString;
	WPAStateType state;
}
@property (nonatomic, retain) NSString *idString;
@property (nonatomic, retain) NSString *nameString;
@property (nonatomic) WPAStateType state;
@end
@implementation WatchApp
@synthesize idString;
@synthesize nameString;
@synthesize state;

@end


@implementation WorkModule
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic enabled;
@dynamic category;
@dynamic name;
@dynamic params;
@synthesize notificationCenter;
@synthesize wsCenter;
@synthesize appsToWatch;
@synthesize tableApps;
@synthesize buttonAdd;
@synthesize buttonRemove;
@synthesize chooseApp;
@synthesize queueName;
@synthesize fidgetFactor, fidgetTimer, fidgetField;


- (IBAction) clickState: (id) sender{
	NSTableView* tView = (NSTableView*)sender;
	int row = [tView selectedRow];
	WatchApp *wa = [[appsToWatch allValues] objectAtIndex:row];
	wa.state = wa.state == WPASTATE_THINKING ? WPASTATE_OFF : WPASTATE_THINKING;
}

- (void) addClosed: (NSNotification*) notification
{
	NSRunningApplication *running = [chooseApp chosenApp];
	if (running){
		if (appsToWatch == nil){
			appsToWatch = [NSMutableDictionary new];
		}
        WatchApp *wa = [WatchApp new];
        [wa setState:WPASTATE_OFF];
        [wa setIdString:[running bundleIdentifier]];
        [wa setNameString: [running localizedName]];
		[appsToWatch setObject:wa forKey: [wa idString]];
		[tableApps noteNumberOfRowsChanged];
	}
}

- (IBAction) clickAdd: (id) sender{
	chooseApp = [[ChooseApp alloc] initWithWindowNibName:@"ChooseApp"];
	[chooseApp showWindow:self];
	[NSApp runModalForWindow:chooseApp.window];

	NSRunningApplication *running = [chooseApp chosenApp];
	if (running){
		if (appsToWatch == nil){
			appsToWatch = [NSMutableDictionary new];
		}
		WatchApp *app = [WatchApp new];
		app.nameString = running.localizedName;
		app.idString = running.bundleIdentifier;
		app.state = WPASTATE_THINKING;
		[appsToWatch setObject:app forKey:[app idString]];
		[tableApps noteNumberOfRowsChanged];
	}
}

- (IBAction) clickRemove: (id) sender{
	NSInteger rowNum = tableApps.selectedRow;
	if (rowNum > -1) {
		//objectValueForTableColumn:row:
		WatchApp *app = [[appsToWatch allValues] objectAtIndex:rowNum];
        [appsToWatch removeObjectForKey:[app idString]];
		[tableApps noteNumberOfRowsChanged];
	}
}

- (NSString*) queueName 
{
	if (!queueName) {
		NSString *base = [params objectForKey:@"queuename"];
		queueName = [Queues queueNameFor:WPA_STATEQUEUE 
								fromBase:base];
	}
	return queueName;
}

- (void) handleReallyActiveApp: (NSTimer*) timer
{
    NSDictionary *appInfo = [[NSWorkspace sharedWorkspace] activeApplication];
    NSString *appBundle = [appInfo objectForKey:@"NSApplicationBundleIdentifier"];
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:WPASTATE_FREE] forKey:@"state"];
	NSString *stateStr =  @"free";
    WatchApp *foundApp = [appsToWatch objectForKey:appBundle];
    if (foundApp){

        if(foundApp.state == WPASTATE_THINKING){
            [notificationCenter postNotificationName:[self queueName]
                                              object: nil 
                                            userInfo:dict];
            dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:WPASTATE_THINKING] forKey:@"state"];
            stateStr = @"work";
        }
        else if (foundApp.state == WPASTATE_OFF){
            //	NSLog(@"WorkModule ignoring %@", appBundle);
            return;
        }
        
    }
	//NSLog(@"WorkModule going to %@ state = %@ sent on %@", appBundle, stateStr, [self queueName]);
	[notificationCenter postNotificationName:[self queueName] 
									  object: nil 
									userInfo:dict];
}

- (void) handleNewActiveApp: (NSNotification*) notification
{
    if (fidgetTimer != nil){
        [fidgetTimer invalidate];
    }
    fidgetTimer = [NSTimer scheduledTimerWithTimeInterval:fidgetFactor 
                                                   target:self 
                                                 selector:@selector(handleReallyActiveApp:) 
                                                 userInfo:nil 
                                                  repeats:NO];
}

-(void) startValidation: (NSObject*) callback  
{
	[super startValidation:callback];
    fidgetFactor = [fidgetField doubleValue];
	[validationHandler performSelector:@selector(validationComplete:) 
							withObject:nil];	
}

- (void) initNotificationCenter
{
#ifdef DEBUG
	//NSLog(@"WorkModule listening for activation now...");
#warning WorkModule in DEBUG mode
#endif
	notificationCenter = [NSDistributedNotificationCenter defaultCenter];
	[notificationCenter addObserver:self 
						   selector:@selector(handleNewActiveApp:) 
							   name:@"NSWorkspaceDidActivateApplicationNotification"
							 object:nil];
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(handleNewActiveApp:)
															   name:nil object:nil];}

- (void) changeState:(WPAStateType)  newState
{
#ifdef DEBUG
#warning WorkModule in debug mode 
	//NSLog(@"WorkModule changing to %d", newState);
#endif
	if (notificationCenter == nil) {
#ifdef DEBUG
		//NSLog(@"WorkModule listening for activation now...");
#endif		
		[self initNotificationCenter];
	}
}


-(void) loadView
{
	[super loadView];
	[tableApps setDataSource:self];
    [fidgetField setStringValue:[NSString stringWithFormat:@"%f",fidgetFactor]];
}

-(void) loadDefaults
{
	[super loadDefaults];

	NSArray *names = [super loadDefaultForKey: @"Names"];
	NSArray *ids = [super loadDefaultForKey: @"Ids"];
	NSArray *states = [super loadDefaultForKey: @"States"];
	appsToWatch = [NSMutableDictionary dictionaryWithCapacity: [names count]];
	for (int i = 0; i < [names count]; i++){
		WatchApp *app = [WatchApp new];
		app.nameString = [names objectAtIndex:i];
		app.idString = [ids objectAtIndex: i];
		app.state = [((NSNumber*)[states objectAtIndex: i]) intValue];
		[appsToWatch setObject: app forKey:[app idString]];
	}
    fidgetFactor = [super loadDoubleDefaultForKey:@"FidgetFactor"];
    if (fidgetFactor == 0.0f)
        fidgetFactor = 0.2f;
}


-(void) clearDefaults
{
	[super clearDefaults];
	[super clearDefaultValue:nil forKey:@"States"];
	[super clearDefaultValue:nil forKey:@"Ids"];
	[super clearDefaultValue:nil forKey:@"Names"];
	[super clearDefaultValue:nil forKey:@"FidgetFactor"];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) saveDefaults
{
	[super saveDefaults];
	NSMutableArray *names = [NSMutableArray new];
	NSMutableArray *ids = [NSMutableArray new];
	NSMutableArray *states = [NSMutableArray new];
	for (WatchApp *app in [appsToWatch allValues]){
		[names addObject: app.nameString];
		[ids addObject: app.idString];
		[states addObject: [NSNumber numberWithInt:app.state]];
	}
	[super saveDefaultValue: states forKey: @"States"];
	[super saveDefaultValue: names forKey: @"Names"];
	[super saveDefaultValue: ids forKey: @"Ids"];
	[super saveDefaultValue: [NSNumber numberWithDouble:fidgetFactor] forKey: @"FidgetFactor"];
	[[NSUserDefaults standardUserDefaults] synchronize];		
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        notificationCenter = nil;
        fidgetFactor = 0.2;
    }
    return self;
}

- (id) init 
{
	self = [super init];
	if (self){
		notificationCenter = nil;
        fidgetFactor = 0.2;
	}
	return self;
}
 
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil params: appParams{
#if DEBUG
	//NSLog(@"WorkModule initWithNibName");
#endif
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil params:appParams];
	if (self){
		WatchApp *app = [[WatchApp alloc] init];
	//	app.idString = @"com.apple.Xcode";
	//	app.nameString = @"Xcode";
		app.idString = @"com.apple.calculator";
		app.nameString = @"calculator";
		app.state = WPASTATE_THINKING;
		appsToWatch = [NSMutableDictionary new];
		[appsToWatch setObject:app forKey:[app idString]];
        fidgetFactor = 0.2;
	}
	return self;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [appsToWatch count];
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSArray *appsArray = [appsToWatch allValues];
    NSParameterAssert(row >= 0 && row < [appsArray count]);
    WatchApp *app  = [appsArray objectAtIndex:row];
	NSString *colId = (NSString*) [tableColumn identifier];
	if ([colId isEqualToString:@"COL1"]){
		theValue = app.nameString;
	}
	if ([colId isEqualToString:@"COL2"]){
		if (app.state == WPASTATE_THINKING){
			theValue = [NSNumber numberWithInt:0];
		}else {
			theValue = [NSNumber numberWithInt:1];

		}

	}
	    return theValue;
}



@end
