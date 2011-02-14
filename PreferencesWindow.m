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
@synthesize modulesTable, amwControl,addButton, removeButton, newModuleView, tableData, 
launchOnBootButton, editButton;

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

}

- (void) showWindow:(id)sender
{
	[super showWindow:sender];
	Context *ctx = [Context sharedContext];
	LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
	[launchOnBootButton setIntValue: [lALCtrl launchAtLogin]];
	
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

- (BOOL) addToLogin
{
	LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
	[lALCtrl setLaunchAtLogin:YES];
	return YES;
}

- (BOOL) removeFromLogin
{
	LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
	[lALCtrl setLaunchAtLogin:NO];
	return YES;
}

- (IBAction) clickLaunchOnBoot: (id) sender
{	BOOL isOK;
	Context *ctx = [Context sharedContext];
	if (launchOnBootButton.state == NSOffState){
		isOK = [self removeFromLogin];
	} else {
		isOK = [self addToLogin];
	}
	if (isOK)
	{
		[ctx saveDefaults];

	} else {
		// back out the change to the checkbox on failure
		LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
		[launchOnBootButton setState: [lALCtrl launchAtLogin]];
	}
}

- (IBAction) clickUseHotKey: (id) sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:@"For your information" 
									 defaultButton:nil alternateButton:nil 
									   otherButton:nil 
						 informativeTextWithFormat:@"This change will not take effect until you quit and restart."];
	[alert runModal];	
	
}

@end
