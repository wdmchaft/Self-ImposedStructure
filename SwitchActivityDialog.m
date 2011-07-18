//
//  SwitchActivityDialog.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SwitchActivityDialog.h"
#import "Context.h"
#import "TaskList.h"
#import "Queues.h"
#import "WPADelegate.h"
#import "WriteHandler.h"

@implementation SwitchActivityDialog
@synthesize oldListsButton, newListsButton, okButton, cancelButton, newActCombo, oldActCombo, newList,
oldList, currentText, completeButton, newData, oldData, newProjPopUp, oldProjPopUp;

- (void) awakeFromNib
{
	NSLog(@"here");

}

- (id<TaskList>) listForName: (NSString*)name
{
	Context *ctx = [Context sharedContext];
	NSArray *lists = [ctx getTrackedLists];
	for (id<TaskList> tl in lists){
		if ([[tl name] isEqualToString:name])
			return tl;
	}
	return nil;
}

- (void) clickNewListItem: (id) sender
{
	NSMenuItem *item = [newListsButton selectedItem];
	NSString *selected = [item title];
	
	[newActCombo setStringValue:@""];
	newList  = [self listForName:selected];
	if (newList  == nil){
		[newActCombo setEnabled:NO];
	} else {
		[newData setList:newList];
		[newActCombo setEnabled:YES];
		[newActCombo reloadData];
	}
	
}

- (void) clickOldListItem: (id) sender
{
	NSMenuItem *item = [oldListsButton selectedItem];
	NSString *selected = [item title];
	
	[oldActCombo setStringValue:@""];
	oldList  = [self listForName:selected];
	if (oldList  == nil){
		[oldActCombo setEnabled:NO];
	} else {
		[oldData setList:oldList];
		[oldActCombo setEnabled:YES];
		[oldActCombo reloadData];
	}	
}

- (void) initGuts
{
	Context *ctx = [Context sharedContext];
	NSString *currentStr =  [[ctx currentTask] objectForKey: @"name"];
	NSString *currentSrc =  [[ctx currentTask] objectForKey: @"source"];
	NSString *currentPrj =  [[ctx currentTask] objectForKey: @"project"];
	currentStr = (currentStr) ? currentStr : @"Just Puttering Around";
	NSArray *lists = [ctx getTrackedLists];
	newList = nil;
	oldList = nil;
	
	NSMenuItem *oldItem = nil;
	NSMenuItem *newItem = nil;
	for (id<TaskList> tl in lists){
		[newListsButton addItemWithTitle:[tl name]];
		[oldListsButton addItemWithTitle:[tl name]];

		oldItem = [oldListsButton itemWithTitle:[tl name]];
		newItem = [newListsButton itemWithTitle:[tl name]];
		[oldItem setTarget:self];	
		[oldItem setAction:@selector(clickOldListItem:)];	
		[newItem setTarget:self];	
		[newItem setAction:@selector(clickNewListItem:)];
		if ([currentSrc isEqualToString:[tl name]]){
			[newListsButton selectItem:newItem];
			[oldListsButton selectItem:oldItem];
			newList = tl;
			oldList = tl;
		}
	}
	if (!oldList){
		oldList = [[ctx instancesMap] objectForKey:[ctx defaultSource]];
	}
	if (!newList){
		newList = [[ctx instancesMap] objectForKey:[ctx defaultSource]];	
	}
	newData = [[ActivityComboData alloc]init];
	oldData = [[ActivityComboData alloc]init];
	[newData setList:newList];
	[oldData setList:oldList];
	[newActCombo setDataSource:newData];
	[oldActCombo setDataSource:oldData];
	[newActCombo reloadData];
	[oldActCombo reloadData];
	WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication]delegate];
	NSArray *projNames = [del allActiveProjects];
	for (NSString *name in projNames) {
		[oldProjPopUp  addItemWithTitle:name];
		[newProjPopUp  addItemWithTitle:name];
		if (oldList && [[oldList defaultProject] isEqualToString: name]){
			[oldProjPopUp  selectItemAtIndex:[projNames indexOfObject:name]];
		}
		if (newList && [[newList defaultProject] isEqualToString: name]){
			[newProjPopUp  selectItemAtIndex:[projNames indexOfObject:name]];
		}	 
	}
	//lastly set the combo boxes values
	[oldActCombo setStringValue: currentStr];
	[newActCombo setStringValue: [Context defaultTaskName]];
	
//	NSDictionary *task = [ctx currentTask];
}

- (void) windowDidLoad
{
	[self initGuts];
}

- (void) showWindow: (id) sender
{
	[super showWindow: sender];
	[self initGuts];
}

- (void) clickNewLists: (id) sender
{
	NSString *title = [[newListsButton selectedItem] title];
	BOOL disableNew = [title isEqualToString:@"None Selected"] ;
	[newActCombo setEnabled:!disableNew];
	 if (disableNew){
		 [newActCombo setStringValue:@""];
		 [newProjPopUp selectItemAtIndex:0];
	 } else {
		 [newProjPopUp  selectItemWithTitle:title];
	}	
}
	 
- (void) clickOldLists: (id) sender
{
	NSString *title = [[oldListsButton selectedItem] title];
	BOOL disableOld = [title isEqualToString:@"None Selected"] ;
	[oldActCombo setEnabled:!disableOld];

	if (disableOld){
		[oldActCombo setStringValue:@""];
	}
	else {
		[oldProjPopUp selectItemWithTitle:title];
	}	
}

- (void) createTaskIfNecessary: (NSString*) task source: (NSString*) srcName project: (NSString*) projName
{
	[WriteHandler sendNewTask: task 
					   source:srcName 
					 project: projName];

}

- (void) swapTasks:(NSString*) newTsk 
			newProject: (NSString*) newProj 
			 newSource: (NSString*) newSrc
			 startDate: (NSDate*)   start
			   oldTask: (NSString*) oldTsk
			oldProject: (NSString*) oldProj
			 oldSource: (NSString*) oldSrc
{
	[WriteHandler sendSwapTasks: newTsk
					 newProject: newProj 
					  newSource: newSrc
					  startDate:start 
						oldTask:oldTsk
					 oldProject:oldProj 
					  oldSource:oldSrc];
}

- (void) sendComplete: (NSDictionary*) task
{
	[WriteHandler sendCompleteTask:[task objectForKey:@"name"] 
						   project:[task objectForKey:@"project"] 
							source:[task objectForKey:@"source"] 
						  doneDate:[NSDate date]];
}

- (void) okDone
{
	// now set the new task

	Context *ctx = [Context sharedContext];
	
	NSString *nName = [newActCombo stringValue];
	NSPopUpButton *nlb = newListsButton;
	NSString *nSrc = ([nlb indexOfSelectedItem] == 0) ? nil : [[newListsButton selectedItem] title];
	NSString *nProj = [[newProjPopUp selectedItem] title];
	NSMutableDictionary *newTask = [NSMutableDictionary dictionaryWithObjectsAndKeys:nName, @"name", nProj, @"project", nil];
	if (nSrc){
		[newTask setObject:nSrc forKey:@"source"];
	}
	[ctx setCurrentTask: newTask ];
	[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"New activity: %@",nName]];
	
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc postNotificationName:[Queues queueNameFor:WPA_ACTIVEQUEUE fromBase:[ctx queueName]]
					   object:nil 
					 userInfo: [NSDictionary dictionaryWithObjectsAndKeys:nName, @"name",
								nSrc, @"source",nil]];
	[NSApp stopModal];
	[super.window close];
}

- (void) clickOk: (id) sender
{
	Context *ctx = [Context sharedContext];
	
	// deal with the old task
	
	// now deal with the previous task
	// first has the task to be saved been changed from the current task
	NSString *oName = [oldActCombo stringValue];
	NSPopUpButton *olb = oldListsButton;
	NSString *oSrc = ([olb indexOfSelectedItem] == 0) ? nil : [[oldListsButton selectedItem] title];
	NSString *oProj = [[oldProjPopUp selectedItem] title];
	NSDictionary *cTask = [ctx currentTask];
	NSString *cName = [cTask objectForKey:@"name"];
	NSString *cSrc = [cTask objectForKey:@"source"];
	NSString *cProj = [cTask objectForKey:@"project"];
	BOOL srcEqual = (!oSrc && !cSrc) || (oSrc && cSrc && [oSrc isEqualToString:cSrc]);
	if ((![oName isEqualToString:cName]) ||
		  (!srcEqual) || (![oProj isEqualToString:cProj])) {
		[self createTaskIfNecessary:oName source:oSrc project:oProj];
		[self swapTasks:oName
			 newProject: oProj 
			  newSource: oSrc
			  startDate: nil
				oldTask: cName
			 oldProject: cProj
			  oldSource: cSrc];
		[ctx setCurrentTask:[NSDictionary dictionaryWithObjectsAndKeys:oProj, @"project", oName, @"name", oSrc, @"source", nil]]; 
	}
	// complete button is set
	if ([completeButton intValue] > 0){
		if (oSrc){
			[self sendComplete:[ctx currentTask]];
			id<TaskList> list = [[ctx instancesMap] objectForKey:oSrc];
			[list markComplete:[ctx currentTask] completeHandler:self selector:@selector(okDone )];
		}
	}
	else {
		[self okDone];
	}

	// now set the new task
	
	NSString *nName = [newActCombo stringValue];
	NSPopUpButton *nlb = newListsButton;
	NSString *nSrc = ([nlb indexOfSelectedItem] == 0) ? nil : [[newListsButton selectedItem] title];
	NSString *nProj = [[newProjPopUp selectedItem] title];
	NSMutableDictionary *newTask = [NSMutableDictionary dictionaryWithObjectsAndKeys:nName, @"name", nProj, @"project", nil];
	if (nSrc){
		[newTask setObject:nSrc forKey:@"source"];
	}
	[ctx setCurrentTask: newTask ];
	[[ctx growlManager] growlFYI:[NSString stringWithFormat: @"New activity: %@",nName]];

	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	[dnc postNotificationName:[Queues queueNameFor:WPA_ACTIVEQUEUE fromBase:[ctx queueName]]
					   object:nil 
					 userInfo: [NSDictionary dictionaryWithObjectsAndKeys:nName, @"name",
								nSrc, @"source",nil]];
	
	[super.window close];
}

- (void) clickCancel: (id) sender
{
	[super.window close];
}
@end
