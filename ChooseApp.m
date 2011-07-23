//
//  ChooseApp.m
//  Self-Imposed Structure
//
//  Created by Charles on 2/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "ChooseApp.h"


@implementation ChooseApp
@synthesize cbRunningApps;
@synthesize buttonOk;
@synthesize buttonCancel;
@synthesize allApps;
@synthesize chosenApp;
@synthesize appsDict, appNames;

- (IBAction) clickOk: (id) sender{
	//NSLog(@"index = %d allApps size = %d",popUpRunningApps.indexOfSelectedItem, [allApps count]);
	chosenApp = [appsDict objectForKey:[cbRunningApps stringValue]];
    if (!chosenApp)
        return;
	[super.window close];
	[NSApp stopModal];
}
- (IBAction) clickCancel: (id) sender{
	[super.window close];
[NSApp stopModal];
}

- (void) showWindow:(id)sender
{
	[super showWindow:sender];
	//[NSApp runModalForWindow:[super window]];
	chosenApp = nil;
    NSArray *running = [[NSWorkspace sharedWorkspace]  runningApplications];
    appsDict = [NSMutableDictionary dictionaryWithCapacity:[running count]];
    for (NSRunningApplication *app in running){
        if ([app bundleIdentifier] != nil){
            [appsDict setValue:app forKey:[NSString stringWithFormat:@"%@ [%@]", [app localizedName], [app bundleIdentifier]]];
        }
        else {
            [appsDict setValue:app forKey:[app localizedName]];
        }
    }
    appNames = [appsDict allKeys];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [appNames count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	return [appNames objectAtIndex:index];
}
@end
