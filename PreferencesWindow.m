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

@implementation PreferencesWindow
@synthesize modulesTable, amwControl, 
growlIntervalText,addButton, removeButton, newModuleView, tableData, 
startOnLaunchButton, launchOnBootButton, growlStepper, editButton, ignoreSaverButton;
;

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
	[launchOnBootButton setIntValue:(ctx.loadOnLogin == YES)];
	[startOnLaunchButton setIntValue:(ctx.startOnLoad == YES)];
	[ignoreSaverButton setIntValue:(ctx.ignoreScreenSaver == YES)];

	
	[growlIntervalText setStringValue:[[NSString alloc] initWithFormat:@"%d",ctx.growlInterval]];
	[growlStepper setIntValue:ctx.growlInterval];
}

- (IBAction) clickAdd: (NSButton*) sender
{
    if (amwControl == nil) {
        amwControl = [[AddModWinController alloc] initWithWindowNibName:@"AddMod"];
    }
	//	amwControl.tasksHandler = self;
	amwControl.tableData = tableData;
	amwControl.tableView = modulesTable;
	[amwControl setCurrCtrl: nil];
	
//	[amwControl.window makeKeyAndOrderFront:self];
	[amwControl showWindow: self];
}

- (IBAction) clickEdit: (NSButton*) sender
{
	NSInteger rowNum = modulesTable.selectedRow;
	if (rowNum > -1) {
		//objectValueForTableColumn:row:
		NSTableColumn *col = [[modulesTable tableColumns] objectAtIndex:0];
		NSString *instName = [tableData objValueForTableColumn:col row:rowNum];
		
		<Module> mod = [[Context sharedContext].instancesMap objectForKey:instName];
		
		if (amwControl == nil) {
			amwControl = [[AddModWinController alloc] initWithWindowNibName:@"AddMod"];
		}
		amwControl.tableData = tableData;
		amwControl.tableView = modulesTable;
		//    [amwControl.window makeKeyAndOrderFront:nil];
		[amwControl setCurrCtrl: (NSViewController*)mod];
		[amwControl showWindow: self];
		[amwControl.window makeKeyAndOrderFront:self];
	}
}

- (IBAction) clickRemove: (NSButton*) sender{
	NSInteger rowNum = modulesTable.selectedRow;
	if (rowNum > -1) {
		//objectValueForTableColumn:row:
		NSTableColumn *col = [[modulesTable tableColumns] objectAtIndex:0];
		NSString *instName = [tableData objValueForTableColumn:col row:rowNum];
		
		<Module> mod = [[Context sharedContext].instancesMap objectForKey:instName];
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
	<Module> mod = [ctx.instancesMap objectForKey: key];
	mod.enabled = !mod.enabled;
	if (mod.enabled){
		switch (ctx.startingState) {
			case STATE_AWAY:
				[mod goAway];
				break;
			case STATE_PUTZING:
				[mod putter];
				break;
			case STATE_THINKING:
				[mod think];
			case STATE_THINKTIME:
				[mod think];
			default:
				break;
		}
	}
	else {
		[mod stop];
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


- (void) addToLogin
{
	NSBundle *me = [NSBundle mainBundle];
	NSString *template = @"tell application \"System Events\" make new login item at end with properties {path:%@, hidden:false}end tell";
	NSString *script = [NSString stringWithFormat:template,[me executablePath]];
	NSAppleScript *playScript;
	playScript = [[NSAppleScript alloc] initWithSource:script];
	[playScript executeAndReturnError:nil];
}


-(void) removeFromLogin
{
	NSBundle *me = [NSBundle mainBundle];
	NSString *template = @"tell application \"System Events\" get the path of every login item if login item %@ exists then delete login item targetAppPath end if end tell";
	NSString *script = [NSString stringWithFormat:template,[me executablePath]];
	NSAppleScript *playScript;
	playScript = [[NSAppleScript alloc] initWithSource:script];
	[playScript executeAndReturnError:nil];
}

- (IBAction) clickLaunchOnBoot: (id) sender
{
	if (launchOnBootButton.state == NSOffState){
		[self addToLogin];
	} else {
		[self removeFromLogin];
	}
	if (((NSButton*)sender).intValue == 1){
		[Context sharedContext].loadOnLogin = YES;
	} else {
		[Context sharedContext].loadOnLogin = NO;
	}
	[[Context sharedContext] saveDefaults];
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

@end
