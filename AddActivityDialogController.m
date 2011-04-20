//
//  AddActivityDialogController.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/31/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "AddActivityDialogController.h"
#import "Context.h"
#import "WPADelegate.h"
#import "WriteHandler.h"



@implementation AddActivityDialogController
@synthesize okButton;
@synthesize cancelButton;
@synthesize activityCombo;
@synthesize allActivities;

- (void) initCombo
{
	Context *ctx = [Context sharedContext];
	[activityCombo setDataSource:nil];
	NSArray *allTasks = [ctx getTasks];
	allActivities = allTasks;
	for(NSDictionary *info in allTasks){
		[activityCombo addItemWithObjectValue:[info objectForKey:@"name"]];
	}
	if (ctx.currentTask){
		[activityCombo setObjectValue:[ctx.currentTask objectForKey:@"name"]];
	} else {
		[activityCombo setObjectValue:@"No current task"];
	}
	[activityCombo noteNumberOfItemsChanged];
	[activityCombo setCompletes:YES];
}

- (void) windowDidLoad
{
	[self initCombo];
}

- (void) showWindow:(id)sender
{
	[self initCombo];
	[[super window] setLevel:NSFloatingWindowLevel];
    [[super window] setFrameAutosaveName:@"AddActivity"];
	[super showWindow:sender];
}

- (IBAction) clickOK: (id) sender
{
	Context *ctx = [Context sharedContext];
	NSComboBox *cb = activityCombo;
	
	ctx.currentTask = nil;
	NSString *str = [cb objectValueOfSelectedItem];
	
	for (NSDictionary *info in allActivities){
		if ([[info objectForKey:@"name"] isEqualToString:str]){
			ctx.currentTask = info;
			break;
		}
	}
	
	// if we get don't get the default or empty then it is "adhoc" task  (with no source)
	
	if (ctx.currentTask == nil){
		if (![cb.stringValue isEqualToString:@"No current task"] && [cb.stringValue length] > 0) {
			NSDictionary *newTI = [NSDictionary	dictionaryWithObject:cb.stringValue forKey:@"name"];
			ctx.currentTask = newTI;
		}
	}
	[ctx saveTask];
	if (ctx.currentTask != nil){
		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"Current activity: %@",[ctx.currentTask objectForKey:@"name"]]];
	} else {
		[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"Current activity not set"]];
	}
	[super.window close];
}

- (IBAction) clickCancel: (id) sender
{
	[super.window close];

}

//- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
//{
//	int index = [uncompletedString length]-1;
//	for (AAMenuObj *amo in allActivities){
//		NSDictionary *dict = amo.dict;
//		NSString *name = [dict objectForKey:@"name"];
//		if ([[name substringToIndex:index] isEqualToString:uncompletedString] ){
//			return name;
//		}
//	}
//	return nil;
//}
//
//- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
//{
//	return [allActivities count];
//}
//
////- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
//
//- (NSUInteger) comboBox: (NSComboBox *) acb indexOfItemWithStringValue: (NSString*) aString
//{
//	NSUInteger ret = 0;
//	for (AAMenuObj *amo in allActivities){
//		NSString *name = [amo.dict objectForKey:@"name"];
//		if ([name isEqualToString:aString] ){
//			return ret;
//		}
//		ret++;
//	}
//	return NSNotFound;
//}
//
////- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
//- (id) comboBox: (NSComboBox *) aComboBox objectValueForItemAtIndex: (NSInteger) index
//{
//	AAMenuObj *amo = [allActivities objectAtIndex:index];
//
//	return amo.dict;
//}
@end
