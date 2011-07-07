//
//  PreferencesWindow.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/1/11.
//  Copyright 2011 zer0gravitas.com. All rights reserved.
//

#import "PreferencesWindow.h"
#import "Columns.h"
#import "WPADelegate.h"
#import "Instance.h"
#import "LaunchAtLoginController.h"
#import "ColorWellCell.h"

@implementation PreferencesWindow
@synthesize modulesTable, amwControl,addButton, removeButton, newModuleView, tableData, 
launchOnBootButton, editButton, hudTable, heatTable, 
summaryField, summaryStepper, summaryLabel, summaryLabel2, summaryButton, editModuleSession, hkControl, 
preHKButton, useHKButton, hkTarget, hkSelector, gotKey;

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
	//NSLog(@"instances size: %lu", [instances count]);
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
	hudTable.dataSource = [Context sharedContext].hudSettings;
	[hudTable registerForDraggedTypes:
	 [NSArray arrayWithObject:[[HUDSettings class] description] ]];
	
    HeatMap *settings = [Context sharedContext].heatMapSettings;
	heatTable.dataSource = settings;
    NSTableColumn *col = [heatTable.tableColumns objectAtIndex:1];
    [col setDataCell:[ColorWellCell new]];
}
//	@param modifierFlags The modifer flags, ( <tt>NSCommandKeyMask</tt>, <tt>NSControlKeyMask</tt>, <tt>NSAlternateKeyMask</tt>, <tt>NSShiftKeyMask</tt> ).

- (NSString*) stringForKeyEvent:(NDHotKeyEvent*) ev
{
	unichar buf[5];
	NSUInteger bufIdx = 0;
	NSUInteger flags = [ev modifierFlags];
	if (flags & NSCommandKeyMask) {
		buf[bufIdx++] = 0x2318;
	}
	if (flags & NSControlKeyMask) {
		buf[bufIdx++] = 0x2303;
	}
	if (flags & NSAlternateKeyMask) {
		buf[bufIdx++] = 0x2325;
	}
	if (flags & NSShiftKeyMask) {
		buf[bufIdx++] = 0x2325;
	}
	buf[bufIdx++] = [ev character];
	return [NSString stringWithCharacters:buf length:bufIdx];
}

- (void) showWindow:(id)sender
{
	[super showWindow:sender];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(close:)
												 name:NSWindowWillCloseNotification 
											   object:[self window]];
	
    [[super window] setFrameAutosaveName:@"Preferences"];
	LaunchAtLoginController *lALCtrl = [LaunchAtLoginController new];
	[launchOnBootButton setIntValue: [lALCtrl launchAtLogin]];
	NDHotKeyEvent *hkEvent = [[Context sharedContext] hotkeyEvent];
	BOOL useKey = hkEvent != nil;
	[useHKButton setIntValue:useKey];
	[hkControl setEnabled:useKey];
	[preHKButton setEnabled:useKey];
	if (useKey){
		[hkControl setStringValue:[hkEvent stringValue]];
	}
	gotKey = NO;
	[hkControl setDelegate:self];
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
	amwControl.hudView = hudTable;
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
		id<Instance> mod = [[Context sharedContext].instancesMap objectForKey:instName];
		amwControl.currCtrl = mod;
		amwControl.tableData = tableData;
		amwControl.tableView = modulesTable;
		amwControl.hudView = hudTable;
		[self runModal];
	}
}

- (IBAction) clickRemove: (NSButton*) sender{
	NSInteger rowNum = modulesTable.selectedRow;
	if (rowNum > -1) {
		//objectValueForTableColumn:row:
		NSTableColumn *col = [[modulesTable tableColumns] objectAtIndex:0];
		NSString *instName = [tableData objValueForTableColumn:col row:rowNum];
		Context *ctx = [Context sharedContext];
		id<Instance> mod = [ctx.instancesMap objectForKey:instName];
		[mod clearDefaults];
		[ctx.instancesMap removeObjectForKey:instName];
		[ctx saveModules];
		if ([mod conformsToProtocol:@protocol(Reporter)]){
			[ctx.hudSettings removeInstance:(id<Reporter>)mod];
			[ctx.hudSettings saveToDefaults];
			[hudTable noteNumberOfRowsChanged];
		}
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
	id<Instance> mod = [ctx.instancesMap objectForKey: key];
	
	mod.enabled = !mod.enabled;
	if (mod.enabled == NO && [mod conformsToProtocol:@protocol(Reporter)]){
		[ctx.hudSettings disableInstance:(id<Reporter>)mod]; // disabled module can not be enabled for summary
	}
	if ([((NSObject*)mod) respondsToSelector:@selector(changeState:)])
	{
		id<Stateful> sc = (id<Stateful>) mod;
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
	BOOL hkOn = [sender intValue] != 0;
	[hkControl setEnabled:hkOn];
	[preHKButton setEnabled:hkOn];
	NDHotKeyEvent *ev = [[Context sharedContext] hotkeyEvent];
	if (ev){
		[ev setEnabled:NO];
	}
	if (!hkOn){
		[hkControl setStringValue:@""];
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		[ud setInteger:0 forKey:@"keyCode"];
		[ud setInteger:0 forKey:@"keyModifiers"];
		[ud setInteger:0 forKey:@"keyChar"];
		[[Context sharedContext] setHotkeyEvent:nil];
	}
	else {
		[hkControl setReadyForHotKeyEvent:YES];
	}
}
- (void) hotKeyPicked: (id) sender
{
	[preHKButton setEnabled:YES];
	gotKey = YES;
}

- (void )clickPreHK:(id) sender
{
	[hkControl setReadyForHotKeyEvent:YES];
	[preHKButton setEnabled:NO];
	gotKey = NO;
}

- (IBAction) clickSummary: (id) sender {
	BOOL enabled = summaryButton.intValue;
	[summaryLabel setEnabled:enabled];
	[summaryLabel2 setEnabled:enabled];
	[summaryStepper setEnabled:enabled];
	[summaryField setEnabled:enabled];
}

- (void) close: (NSNotification*) msg
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name: NSWindowWillCloseNotification object:[self window]];
	NDHotKeyEvent *event = [hkControl hotKeyEvent];
	NDHotKeyEvent *oldEvent = [[Context sharedContext] hotkeyEvent];
	BOOL useHK = [useHKButton intValue];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if (event && useHK && gotKey){
		if (oldEvent) {
			[oldEvent setEnabled:NO];
			[oldEvent removeHotKey];
		}
		[ud setInteger:[hkControl character] forKey:@"keyChar"];
		[ud setInteger:[hkControl modifierFlags] forKey:@"keyModifiers"];
		[ud setInteger:[hkControl keyCode] forKey:@"keyCode"];
		[ud setBool:YES forKey:@"useHotKey"];
		NDHotKeyEvent *event = [hkControl hotKeyEvent];
		[event setTarget:hkTarget selector:hkSelector];
		[event setEnabled:YES];
		[[Context sharedContext] setHotkeyEvent:event] ;
	} 
	else {
		[ud setBool:NO forKey:@"useHotKey"];
		
	}
	
	
	[[Context sharedContext]saveDefaults];
}
@end
