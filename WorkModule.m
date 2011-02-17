//
//  WorkModule.m
//  WorkPlayAway
//
//  Created by Charles on 2/14/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "WorkModule.h"
#import "State.h"
#import "ChooseApp.h"

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
@synthesize notificationCenter;
@synthesize wsCenter;
@synthesize appsToWatch;
@synthesize tableApps;
@synthesize buttonAdd;
@synthesize buttonRemove;
@synthesize chooseApp;


- (IBAction) clickState: (id) sender{
	NSTableView* tView = (NSTableView*)sender;
	int row = [tView selectedRow];
	WatchApp *wa = [appsToWatch objectAtIndex:row];
	wa.state = wa.state == WPASTATE_THINKING ? WPASTATE_FREE : WPASTATE_THINKING;
}

- (void) addClosed: (NSNotification*) notification
{
	NSRunningApplication *running = [chooseApp chosenApp];
	if (running){
		if (appsToWatch == nil){
			appsToWatch = [NSMutableArray new];
		}
		[appsToWatch addObject:running];
		[tableApps noteNumberOfRowsChanged];
	}
}

- (IBAction) clickAdd: (id) sender{
	chooseApp = [[ChooseApp alloc] initWithWindowNibName:@"ChooseApp"];
	[chooseApp showWindow:self];
	[NSApp runModalForWindow:chooseApp.window];
//	[[NSNotificationCenter defaultCenter] addObserver:self 
//											 selector:@selector(addClosed:) 
//												 name:NSWindowWillCloseNotification 
//											   object:chooseApp.window];
	NSRunningApplication *running = [chooseApp chosenApp];
	if (running){
		if (appsToWatch == nil){
			appsToWatch = [NSMutableArray new];
		}
		WatchApp *app = [WatchApp new];
		app.nameString = running.localizedName;
		app.idString = running.bundleIdentifier;
		app.state = WPASTATE_THINKING;
		[appsToWatch addObject:app];
		[tableApps noteNumberOfRowsChanged];
	}
}

- (IBAction) clickRemove: (id) sender{
	NSInteger rowNum = tableApps.selectedRow;
	if (rowNum > -1) {
		//objectValueForTableColumn:row:
		[appsToWatch removeObjectAtIndex:rowNum];
		[tableApps noteNumberOfRowsChanged];
	}
	
}

- (void) handleNewActiveApp: (NSNotification*) notification
{
	NSDictionary *dict = [notification userInfo];
	NSRunningApplication *newApp = [dict objectForKey:@"NSWorkspaceApplicationKey"];
	for (WatchApp *wa in appsToWatch){
		if ([wa.idString isEqualToString:newApp.bundleIdentifier]){
			//com.workplayaway.wpa
			NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:wa.state] forKey:@"state"];
			[notificationCenter postNotificationName:@"com.workplayaway.wpa" object: nil userInfo:dict];
		}
	}
}

-(void) startValidation: (NSObject*) callback  
{
	[super startValidation:callback];
	[validationHandler performSelector:@selector(validationComplete:) 
							withObject:nil];	
}

- (void) initNotificationCenter
{
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
	if (notificationCenter == nil)
		[self initNotificationCenter];
}


-(void) loadView
{
	[super loadView];
	[tableApps setDataSource:self];
	
}

-(void) loadDefaults
{
	[super loadDefaults];

	NSArray *names = [super loadDefaultForKey: @"Names"];
	NSArray *ids = [super loadDefaultForKey: @"Ids"];
	NSArray *states = [super loadDefaultForKey: @"States"];
	appsToWatch = [[NSMutableArray alloc]initWithCapacity: [names count]];
	for (int i = 0; i < [names count]; i++){
		WatchApp *app = [WatchApp new];
		app.nameString = [names objectAtIndex:i];
		app.idString = [ids objectAtIndex: i];
		app.state = [((NSNumber*)[states objectAtIndex: i]) intValue];
		[appsToWatch addObject: app];
	}
}


-(void) clearDefaults
{
	[super clearDefaults];
	[super clearDefaultValue:nil forKey:@"States"];
	[super clearDefaultValue:nil forKey:@"Ids"];
	[super clearDefaultValue:nil forKey:@"Names"];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) saveDefaults
{
	[super saveDefaults];
	NSMutableArray *names = [NSMutableArray new];;
	NSMutableArray *ids = [NSMutableArray new];;
	NSMutableArray *states = [NSMutableArray new];;
	for (WatchApp *app in appsToWatch){
		[names addObject: app.nameString];
		[ids addObject: app.idString];
		[states addObject: [NSNumber numberWithInt:app.state]];
	}
	[super saveDefaultValue: states forKey: @"States"];
	[super saveDefaultValue: names forKey: @"Names"];
	[super saveDefaultValue: ids forKey: @"Ids"];
	[[NSUserDefaults standardUserDefaults] synchronize];		
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		WatchApp *app = [[WatchApp alloc] init];
	//	app.idString = @"com.apple.Xcode";
	//	app.nameString = @"Xcode";
		app.idString = @"com.apple.calculator";
		app.nameString = @"calculator";
		app.state = WPASTATE_THINKING;
		appsToWatch = [NSMutableArray new];
		[appsToWatch addObject:app];
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
    NSParameterAssert(row >= 0 && row < [appsToWatch count]);
    WatchApp *app  = [appsToWatch objectAtIndex:row];
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
