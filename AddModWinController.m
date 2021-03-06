//
//  AddModWinController.m
//  Self-Imposed Structure
//
//  Created by Charles on 12/2/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "AddModWinController.h"
#import "Context.h"
#import "Reporter.h"
#import "BaseInstance.h"

@implementation AddModWinController
@synthesize okButton, cancelButton, typeButton, configBox, nothingView, currCtrl, indicator, nameText,tableData,
tableView, modNames, originalName, hudView;


- (void) clickOk: (id) sender
{
	if ([nameText.stringValue length] == 0){
		NSAlert *alert = [NSAlert alertWithMessageText:nil 
										 defaultButton:nil
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"Name must be filled in!" ];
		[alert runModal];
		return;
	}
	if ([[super window].title isEqualToString: @"Add Module"]){ // check for dups on add
		if ([[Context sharedContext].instancesMap objectForKey: nameText.stringValue]){
			NSString *err = [NSString stringWithFormat: @"%@ duplicates existing module name.",nameText.stringValue];
			NSAlert *alert = [NSAlert alertWithMessageText:nil
										 defaultButton:nil
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:err];
			[alert runModal];
			return;
		}
	}
	id<Instance> mod = (id<Instance>) currCtrl;
	mod.name = nameText.stringValue.copy;
	[indicator setHidden:NO];
	[indicator startAnimation:self];
	[mod startValidation:self];
}

-(void) validationComplete: (NSString*) msg
{
	Context *ctx = [Context sharedContext];
	[indicator stopAnimation:self];
	[indicator setHidden:YES];
	if (msg){
		NSAlert *alert = [NSAlert new];
		alert.messageText = msg;
		[alert runModal];
		return;
	}
	 id<Instance> mod = (id<Instance>) currCtrl;
	// if there is no original name we are adding a module - otherwise modifying existing module
	if (originalName == nil){
		mod.enabled = YES;  // enable it if new
	}
	[mod saveDefaults];
	NSMutableDictionary *modsMap = [Context sharedContext].instancesMap;
	if (originalName == nil || [originalName isEqualToString: mod.name]){
		[modsMap setObject: mod forKey: mod.name];
		if ([mod conformsToProtocol:@protocol(Reporter)] && originalName == nil){
			[ctx.hudSettings addInstance:(id<Reporter>) mod ];
		}	
	} 
	else {
		[modsMap removeObjectForKey:originalName];
		[ctx removeDefaultsForKey:originalName];
	
		[modsMap setObject: mod forKey: mod.name];
	}
	[mod clearValidation];
	tableData.instances = modsMap;
	[ctx saveModules];
	if ([mod conformsToProtocol:@protocol(Reporter)]){
		[ctx.hudSettings saveToDefaults];
	}
	[tableView noteNumberOfRowsChanged];
	[ctx modulesChanged];
	[super.window close];
}

- (void) initFields
{
	[typeButton selectItemAtIndex:0];
	if (currCtrl == nil){
		configBox.title = @"No Module Specific Settings";
		[nameText setEnabled:NO];
		[nameText setStringValue:@""];
		configBox.contentView = nothingView;
		[okButton setEnabled:NO];
		[typeButton setEnabled: YES];
		[[super window] setTitle: @"Add Module"];
	} 
	else {
		[[super window] setTitle: @"Edit Module"];

		id<Instance> mod = (id<Instance>) currCtrl;
		originalName = mod.name.copy;
		NSString *modDesc = [[Context sharedContext] descriptionForModule: mod];
		[typeButton selectItemWithTitle: modDesc];
		[typeButton setEnabled: NO];
		configBox.title = @"No Module Specific Settings";
		[mod loadDefaults];
		[currCtrl loadView];
		configBox.contentView = currCtrl.view;

		configBox.title = [NSString stringWithFormat:@"%@ Specific Settings:",modDesc];
		[nameText setEnabled:YES];
		[nameText setStringValue:mod.name];
		[okButton setEnabled:YES];
	}
}
-(void) showWindow:(id)sender{
	[super showWindow:sender];
	if (typeButton != nil) {
		[self initFields];
	}
	[self.window makeKeyAndOrderFront:self];
}

-(void) clickCancel: (id) sender
{
	[super.window close];
}

-(void) windowDidLoad
{
	
	NSPopUpButton *tb = typeButton;
	Context *ctx = [Context sharedContext];
	[tb removeAllItems];
	modNames = [[NSMutableArray alloc]initWithCapacity:[ctx.bundlesMap count]];
	[tb addItemWithTitle:@"[Not Selected]"];
	[modNames addObject:@"[Not Selected]"];
	for (NSString *name in ctx.bundlesMap){
		[modNames addObject:name];
		NSBundle *bundle = [ctx.bundlesMap objectForKey: name];
		NSString *dispName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		dispName = (dispName == nil) ? name : dispName;
		[tb addItemWithTitle:dispName];
	}
	[self initFields];
	[indicator setHidden:YES];
    [[super window] setFrameAutosaveName:@"AddModule"];
}

-(void) clickType :(id) sender
{
	Context *ctx = [Context sharedContext];
	NSNumber *itemNum = typeButton.objectValue;
	NSString *pluginName = [modNames objectAtIndex: [itemNum intValue]];
	NSDictionary *map = ctx.bundlesMap;
	NSBundle *modBundle = [map objectForKey:pluginName];

	currCtrl = nil;
	[nameText setEnabled:NO];
	[nameText setStringValue:@""];
	configBox.title = @"No Module Specific Settings";
	NSView *modView = nothingView;
	if (modBundle != nil){
		Class modClass = modBundle.principalClass;
		currCtrl = [modClass alloc];
		//
		// the NIB name should match the plugin
		//
		BaseInstance *temp = [modClass alloc];
		temp = [temp initWithNibName:pluginName bundle:modBundle params:ctx.params];
		currCtrl = temp;
		NSString *dispName = [[Context sharedContext] descriptionForModule:((id<Instance>)currCtrl)];
		modView= currCtrl.view;
		dispName = dispName == nil ? [modClass description] : dispName;
		((id<Instance>)currCtrl).name = dispName.copy;
		nameText.stringValue = dispName.copy;
		configBox.title = [NSString stringWithFormat:@"%@ Specific Settings:",dispName];
//		currCtrl = [modClass alloc];	
		[okButton setEnabled:YES];
		[nameText setEnabled:YES];
	}
	configBox.contentView = modView;
}

@end
