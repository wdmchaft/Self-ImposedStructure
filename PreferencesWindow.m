//
//  PreferencesWindow.m
//  Nudge
//
//  Created by Charles on 1/1/11.
//  Copyright 2011 workplayaway.com. All rights reserved.
//

#import "PreferencesWindow.h"
#import "Columns.h"
#import "WPADelegate.h"
#import "Instance.h"
#import "LaunchAtLoginController.h"

@implementation PreferencesWindow
@synthesize modulesTable, amwControl, 
growlIntervalText,addButton, removeButton, newModuleView, tableData, 
startOnLaunchButton, launchOnBootButton, growlStepper, editButton, ignoreSaverButton,
dailyGoalText, weeklyGoalText, brbText, summaryText, brbStepper, summaryStepper;

- (void)awakeFromNib
{
	NSArray *allCols = modulesTable.tableColumns;
	[modulesTable removeTableColumn:[allCols objectAtIndex:0]];
	[modulesTable removeTableColumn:[allCols objectAtIndex:0]];
	NSTableColumn *col1 = [[NSTableColumn alloc] initWithIdentifier:DESC_COL];
	[[col1 headerCell] setStringValue:DESC_COL];
	[modulesTable addTableColumn: col1];
	[col1 setWidth:225.0];
	NSTableColumn *col2 = [[NSTableColumn alloc] initWithIdentifier:SOURCE_COL];
	[[col2 headerCell] setStringValue:SOURCE_COL];
	[col2 setWidth:125.0];
	[modulesTable addTableColumn: col2];
	NSTableColumn *col3 = [[NSTableColumn alloc] initWithIdentifier:ENABLED_COL];
	[[col3 headerCell] setStringValue:ENABLED_COL];
	
	[modulesTable addTableColumn: col3];
	
	
	Context *ctx = [Context sharedContext];
	NSDictionary *instances = ctx.instancesMap;
	NSLog(@"instances size: %d", [instances count]);
	tableData = [[ModulesTableData alloc] initWithDictionary:instances];
	modulesTable.dataSource = tableData;
	[modulesTable noteNumberOfRowsChanged];
	
	
	
	
    NSButtonCell *cell;
    cell = [[NSButtonCell alloc] init];
    [cell setButtonType:NSSwitchButton];
    [cell setTitle:@""];
    [cell setAction:@selector(toggleModule:)];
    [cell setTarget:self];
	
	[col3 setDataCell:cell];
	[cell release];
	
	workView = modulesTable;
	
	// reset loadOnLogin according to reality
	
	LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
	ctx.loadOnLogin = [lALCtrl launchAtLogin];
}

- (void) showWindow:(id)sender
{
	[super showWindow:sender];
	Context *ctx = [Context sharedContext];
	[launchOnBootButton setIntValue:(ctx.loadOnLogin == YES)];
	[startOnLaunchButton setIntValue:(ctx.startOnLoad == YES)];
	[ignoreSaverButton setIntValue:(ctx.ignoreScreenSaver == YES)];
	
	
	[growlIntervalText setStringValue:[[NSString alloc] initWithFormat:@"%d",ctx.growlInterval]];
	[growlStepper setIntValue:ctx.growlInterval];
	[weeklyGoalText setDoubleValue:(ctx.weeklyGoal/60)];
	[dailyGoalText setDoubleValue:(ctx.dailyGoal/60)];
	[summaryText setDoubleValue:(ctx.timeAwayThreshold/60)];
	[brbText setDoubleValue:(ctx.brbThreshold/60)];
	[summaryStepper setIntValue:(ctx.timeAwayThreshold/60)];
	[brbStepper setDoubleValue:(ctx.brbThreshold/60)];
	[[super window]orderFront:self];
}

- (void) addClosed: (NSNotification*) notification
{
	[NSApp endModalSession:editModuleSession];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name: NSWindowWillCloseNotification 
												  object:amwControl.window];
}
- (void) runModal
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(addClosed:) 
												 name:NSWindowWillCloseNotification 
											   object:amwControl.window];
	editModuleSession = [NSApp beginModalSessionForWindow:amwControl.window];
	[NSApp runModalSession:editModuleSession];
}
- (IBAction) clickAdd: (NSButton*) sender
{
	amwControl = [[AddModWinController alloc] initWithWindowNibName:@"AddMod"];
	amwControl.tableData = tableData;
	amwControl.tableView = modulesTable;
	[amwControl setCurrCtrl: nil];
	
	[self runModal];
}

- (IBAction) clickEdit: (NSButton*) sender
{
	NSInteger rowNum = modulesTable.selectedRow;
	if (rowNum > -1) {
		//objectValueForTableColumn:row:
		NSTableColumn *col = [[modulesTable tableColumns] objectAtIndex:0];
		NSString *instName = [tableData objValueForTableColumn:col row:rowNum];
		amwControl = [[AddModWinController alloc] initWithWindowNibName:@"AddMod"];
		<Instance> mod = [[Context sharedContext].instancesMap objectForKey:instName];
		amwControl.currCtrl = mod;
		amwControl.tableData = tableData;
		amwControl.tableView = modulesTable;
		[self runModal];
	}
}

- (IBAction) clickRemove: (NSButton*) sender{
	NSInteger rowNum = modulesTable.selectedRow;
	if (rowNum > -1) {
		//objectValueForTableColumn:row:
		NSTableColumn *col = [[modulesTable tableColumns] objectAtIndex:0];
		NSString *instName = [tableData objValueForTableColumn:col row:rowNum];
		
		<Instance> mod = [[Context sharedContext].instancesMap objectForKey:instName];
		[mod clearDefaults];
		[[Context sharedContext].instancesMap removeObjectForKey:instName];
		[[Context sharedContext] saveModules];
		[modulesTable noteNumberOfRowsChanged];
	}
}


-(IBAction)toggleModule:(id)sender
{
	NSTableView* tView = (NSTableView*)sender;
	int row = [tView selectedRow];
	Context *ctx = [Context sharedContext];
	NSArray *keys = [ctx.instancesMap allKeys];
	NSString *key = [keys objectAtIndex:row];
	<Instance> mod = [ctx.instancesMap objectForKey: key];
	
	mod.enabled = !mod.enabled;
	if ([((NSObject*)mod) respondsToSelector:@selector(changeState:)])
	{
		<Stateful> sc = (<Stateful>) mod;
		if (mod.enabled){
			[sc changeState:ctx.currentState];
		}
		else {
		
			[sc changeState:WPASTATE_OFF];
		}
	}
	[mod saveDefaults];	
}


-(IBAction) clickStartOnLaunch: (id) sender {
	if (startOnLaunchButton.intValue == 1){
		[Context sharedContext].startOnLoad = YES;
	} else {
		[Context sharedContext].startOnLoad = NO;
	}
	[[Context sharedContext] saveDefaults];
}

- (BOOL) addToLogin
{
	LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
	[lALCtrl setLaunchAtLogin:YES];
	return YES;
}
//- (BOOL) addToLogin
//{
//	NSBundle *me = [NSBundle mainBundle];
//	//NSString *template = @"tell application \"System Events\"\n make new login item at end with properties {path:\"%@\", hidden:false}\nend tell";
//	NSString *script = @"tell application \"System Events\"\n make new login item at end with properties {path:\"";
//	script = [script stringByAppendingString:[me executablePath]];
//	script = [script stringByAppendingString:@"\", hidden:false}\nend tell"];
//	//NSString *script = [NSString stringWithFormat:template,[me executablePath]];
//	NSLog(@"script = %@", script);
//	NSAppleScript *playScript;
//	playScript = [[NSAppleScript alloc] initWithSource:script];
//	NSMutableDictionary *errDict = [NSMutableDictionary new];
//	[playScript executeAndReturnError:&errDict];
//	if ([errDict count] != 0){
//		NSAlert *alert = [NSAlert alertWithMessageText:nil 
//										 defaultButton:nil
//									   alternateButton:nil 
//										   otherButton:nil 
//							 informativeTextWithFormat:@"An error occurred adding the login item. \
//						  You can attempt to add the app from the Users Preferences panel.\
//						  See console log for more details." ];
//		[alert runModal];
//		NSLog(@"Errors running login item remove script ");
//		for (NSString *key in errDict){
//			NSLog(@"%@ = %@",key, [errDict objectForKey:key]);
//		}
//		return NO;
//	} 
//	return YES;
//}

- (BOOL) removeFromLogin
{
	LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
	[lALCtrl setLaunchAtLogin:NO];
	return YES;
}

//-(BOOL) removeFromLogin
//{
//	//NSString *template1 = @"tell application \"System Events\"\n get the path of every login item\n if login item \"%@\" exists then delete login item targetAppPath\n end if\n end tell";
//	NSString *script = @"tell application \"System Events\"\nif login item \"";	
//	script = [script stringByAppendingString:__APPNAME__];
//	script = [script stringByAppendingString:@"\" exists then\ndelete login item \""];
//	script = [script stringByAppendingString:__APPNAME__];
//	script = [script stringByAppendingString: @"\"\n end if\n end tell"];
//	NSLog(@"script:\n%@", script);
////	NSString *script = [NSString stringWithFormat:template,[me executablePath]];
//	NSAppleScript *playScript;
//	playScript = [[NSAppleScript alloc] initWithSource:script];
//	NSMutableDictionary *errDict = [NSMutableDictionary new];
//	[playScript executeAndReturnError:&errDict];
//	if ([errDict count] > 0){
//		NSAlert *alert = [NSAlert alertWithMessageText:nil 
//										 defaultButton:nil
//									   alternateButton:nil 
//										   otherButton:nil 
//							 informativeTextWithFormat:@"An error occurred removing the login item. \
//						  You can attempt to remove the app from the Users Preferences panel.\
//						  See console log for more details." ];
//		[alert runModal];	
//		NSLog(@"Errors running login item remove script ");
//		for (NSString *key in errDict){
//			NSLog(@"%@ = %@",key, [errDict objectForKey:key]);
//		}
//		return NO;
//	}
//	return YES;
//}

- (IBAction) clickLaunchOnBoot: (id) sender
{	BOOL isOK;
	Context *ctx = [Context sharedContext];
	if (launchOnBootButton.state == NSOffState){
		isOK = [self removeFromLogin];
		[Context sharedContext].loadOnLogin = NO;
	} else {
		isOK = [self addToLogin];
	}
	if (isOK)
	{
		ctx.loadOnLogin = (launchOnBootButton.state == NSOffState);
		[ctx saveDefaults];

	} else {
		// back out the change to the checkbox on failure
		[launchOnBootButton setState: ctx.loadOnLogin == YES ? NSOnState : NSOffState];
	}
}


- (IBAction) clickGrowlStepper: (id) sender
{
	int stepVal = growlStepper.intValue;
	growlIntervalText.intValue = stepVal;
	[Context sharedContext].growlInterval = stepVal;
	[[Context sharedContext] saveDefaults];
}

- (IBAction) clickIgnoreSaverButton: (id) sender
{
	if (ignoreSaverButton.intValue == 1){
		[Context sharedContext].ignoreScreenSaver = YES;
	} else {
		[Context sharedContext].ignoreScreenSaver = NO;
	}
	[[Context sharedContext] saveDefaults];
}

-(IBAction) dailyGoalChanged: (id) sender
{
	[Context sharedContext].dailyGoal = (dailyGoalText.intValue * 60);
	[[Context sharedContext] saveDefaults];
}

-(IBAction) weeklyGoalChanged: (id) sender
{
	[Context sharedContext].weeklyGoal  = (weeklyGoalText.intValue * 60);
	[[Context sharedContext] saveDefaults];
}

- (IBAction) clickBRBStepper: (id) sender
{
	int stepVal = brbStepper.intValue;
	brbText.intValue = stepVal;
	[Context sharedContext].brbThreshold = stepVal * 60;
	[[Context sharedContext] saveDefaults];
}

- (IBAction) clickSummaryStepper: (id) sender
{
	int stepVal = summaryStepper.intValue;
	summaryText.intValue = stepVal;
	[Context sharedContext].timeAwayThreshold = stepVal * 60;
	[[Context sharedContext] saveDefaults];
}

- (IBAction) summaryChanged: (id) sender
{
	[Context sharedContext].timeAwayThreshold = [sender intValue] * 60;
}

- (IBAction) brbChanged: (id) sender
{
	[Context sharedContext].brbThreshold = [sender intValue] * 60;

}
@end
