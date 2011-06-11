//
//  TaskDialogController.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/6/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//
#import "Secret.h"
#import "Context.h"
#import "TaskDialogController.h"
#import "RequestREST.h"
//#import "selfstructAppDelegate.h"
#import "CompleteRespHandler.h"
#import "ListsHandler.h"
#import "BaseInstance.h"
#import "Utility.h"
#import "Queues.h"

@implementation TaskDialogController
@synthesize busyIndicator;
@synthesize dueButton;
@synthesize context;
@synthesize tlHandler;
@synthesize nameField;
@synthesize notesField;
@synthesize dueDatePicker;
@synthesize listsCombo;
@synthesize priorityCombo;
@synthesize tdc;
@synthesize currentJob;
@synthesize buttonsMatrix;
@synthesize nilDateLabel;
@synthesize saveView;
@synthesize baseView;
@synthesize listLabel, notesLabel, titleLabel;
@synthesize updateSteps;

- (void) disableEverything
{
	[nameField setEditable:NO];
	[nameField setEnabled:NO];
	[notesField setEditable:NO];
	[notesField setEnabled:NO];
	[dueDatePicker setEnabled:NO];
	[dueButton setEnabled:NO];
	[listLabel setEnabled:NO];
	[titleLabel setEnabled:NO];
	[notesLabel setEnabled:NO];
	[listsCombo setEnabled:NO];
	[priorityCombo setEnabled:NO];
}

- (void) setSteps
{	
	// can have up to 3 distinct steps
	// rename (rtm.tasks.setName)
	// reschedule (rtm.tasks.setDueDate)
	// modify/add/delete note (rtm.tasks.notes. add/delete/update
	updateSteps = [UpdateSteps new];
	NSString *taskName = [tdc objectForKey:@"name"];
	if (![[nameField stringValue] isEqualToString: taskName])
		[updateSteps addStep: updateName];
	NSString *taskNote = [tdc objectForKey:@"note_text"];
	NSString *newNote = [notesField stringValue];
	if ([newNote length] == 0) newNote = nil;
	
	if (taskNote && newNote && ![[notesField stringValue] isEqualToString: taskNote])
		[updateSteps addStep: updateNote];	
	else if (taskNote != newNote)
		[updateSteps addStep: updateNote];	

	NSNumber *hasDate = [tdc objectForKey:@"has_due_time"];
	NSDate *taskDate = [tdc objectForKey:@"due_time"];
	if ([dueButton intValue] == 1) {
		if ([hasDate intValue] ==  0) {
			[updateSteps addStep:updateDate];
		}
		if (![taskDate isEqualToDate:[dueDatePicker dateValue]]) {
			[updateSteps addStep: updateDate];
		}
	}
	else {
		if ([hasDate intValue] == 1) {
			[updateSteps addStep:updateDate];
		}
	}
	int pNum = [[tdc objectForKey:@"priority"] intValue];
	int ddNum = [priorityCombo indexOfSelectedItem];
	if (pNum != ddNum) {
		[updateSteps addStep:updatePriority];
	}
	
}

- (void) clickUpdate: (id) sender
{
	[self disableEverything];
	currentJob = taskActionModify;
	[notesField setEnabled:YES];
	[notesField setEditable:YES];
	[nameField setEnabled:YES];
	[nameField setEditable:YES];
	[titleLabel setEnabled:YES];
	[notesLabel setEnabled:YES];
	[dueButton setEnabled:YES];
	[priorityCombo setEnabled:YES];
	NSDate *dueDate = [tdc objectForKey:@"due_time"];
	if (dueDate){
		[dueDatePicker setEnabled:YES];
		[dueDatePicker setHidden:NO];
		[dueDatePicker setDateValue:dueDate];
	}
}

- (void) clickCancel: (id) sender
{ 
	[self close];
}

-(void) clickComplete: (id) sender
{
	[self disableEverything];
	currentJob = taskActionComplete;
}

-(void) clickDelete: (id) sender
{
	[self disableEverything];
	currentJob = taskActionDelete;	
}

- (IBAction) listChanged: (id) sender{
	[buttonsMatrix setEnabled:NO];
}

- (IBAction) dateChanged: (id) sender{
	[buttonsMatrix setEnabled:NO];
}

- (void) setDateOrNil:(NSDate*) dateVal
{
	NSPoint p;
	if (!dateVal){
		saveView = dueDatePicker;
		p = [dueDatePicker frame].origin;
		[dueDatePicker setHidden:YES];
		[dueDatePicker removeFromSuperview];
		[baseView addSubview:nilDateLabel];
		p.y += 4;
		[nilDateLabel setFrameOrigin:p];
		[nilDateLabel setHidden:NO];
	}
	else {
		saveView = nilDateLabel;
		p = [nilDateLabel frame].origin;
		[nilDateLabel setHidden:YES];
		[nilDateLabel removeFromSuperview];
		[baseView addSubview:dueDatePicker];
		p.y -= 4;
		[dueDatePicker setFrameOrigin:p];
		[dueDatePicker setHidden:NO];
		[dueDatePicker setEnabled:YES];
		[dueDatePicker setDateValue:dateVal];
	}
}

- (void) clickDue:(id)sender
{
	NSDate *temp = nil;
	if ([sender intValue]){
		temp = [NSDate date];
	}
	[self setDateOrNil:temp];
	[buttonsMatrix setEnabled:NO];
}

- (void) sendPriority
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	[newDict setObject:[nameField stringValue] forKey:@"name"];
	[context sendPriority: self 
				 callback:@selector(nextStep) 
				 priority:[priorityCombo indexOfSelectedItem]
					 task:tdc];	
}

- (void) nextStep
{
	updateStep step = [updateSteps getStep];
	switch (step) {
		case updateDone:
			[self simpleDone];
			break;
		case updateDate:
			[self sendDate];
			break;
		case updateName:
			[self sendName];
			break;
		case updateNote:
			[self sendNote];
			break;
		case updatePriority:
			[self sendPriority];
		default:
			break;
	}
	[updateSteps popStep];
}

- (void) sendName
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	[newDict setObject:[nameField stringValue] forKey:@"name"];
	[context sendName: self 
			 callback:@selector(nextStep) 
				 name:[nameField stringValue]
				 task:tdc];	
}

- (void) sendNote
{
	NSString *newText = [notesField stringValue];
	newText = [newText length] == 0 ? nil : newText;
	NSString *oldText = [tdc objectForKey:@"note_text"]; 
		
	[context sendNote:self callback: @selector(nextStep)
			   newVal:newText oldVal: oldText
				 task:tdc];

}

- (void) sendDate
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	int val = [dueButton intValue];
	BOOL hasDate = val != 0;
	[newDict setObject:[NSNumber numberWithBool:hasDate] forKey:@"has_due_time"];
	NSDate *newDate = nil;
	if (hasDate){
		newDate = [dueDatePicker dateValue];
		
	} 
	[context sendDate: self 
			 callback:@selector(nextStep) 
				 date: newDate
				 task:tdc] ;
}

- (void) clickOk: (id) sender
{
	// decide what to do
	switch (currentJob) {
		case taskActionSwitch:
			NSLog(@"switch");
			NSString *newListName = [listsCombo titleOfSelectedItem];
			NSString *newListId = [context.idMapping objectForKey: newListName];			
			[context sendMoveTo:self callback:@selector(simpleDone) list: newListId params:tdc];
			
			break;
			
		case taskActionModify:
			[self setSteps];
			[self nextStep];
			break;
		case taskActionDelete:
			NSLog(@"delete");	
			[self sendDelete];
			break;
		case taskActionComplete:
			[self sendComplete];
			
			break;
			
		default:
			break;
	}
}




- (void) sendDelete
{
	[context sendSimple: self callback:@selector(simpleDone) methodName: @"rtm.tasks.delete" params:tdc];
}

- (void) sendComplete
{
	[context sendComplete: self callback:@selector(simpleDone) params: tdc];

}

- (void) simpleDone
{
	[busyIndicator stopAnimation:self];
	[NSAlert alertWithMessageText:@"Completed!" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"yippie!"];
	BaseTaskList *btList = (BaseTaskList*)[context module];
	NSString *changeQueue = [btList completeQueue];
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center postNotificationName:changeQueue object:nil userInfo: tdc];
	[self close];
}

- (void) setPriorityDD 
{
	NSString* priority = [tdc objectForKey:@"priority"];
	int pNum = [priority intValue];
	[priorityCombo selectItemAtIndex:pNum];
}

- (void) initGuts
{
	[self disableEverything];
	[self setPriorityDD];
	[busyIndicator setHidden:YES];
	[nameField setStringValue:[tdc valueForKey:@"name"]];
	[notesField setStringValue:[tdc valueForKey:@"note_text"]?[tdc valueForKey:@"note_text"]:@""];
	[self loadLists];
	currentJob = taskActionComplete;
	[buttonsMatrix setState:YES atRow:0 column:0];
	NSDate *dueDate = [tdc objectForKey:@"due_time"];
	BOOL hasDue = [[tdc objectForKey:@"has_due_time"] intValue];
	if (hasDue){
		[dueDatePicker setHidden:NO];
		[dueButton setIntValue:YES];
		[dueDatePicker setDateValue:dueDate];
		saveView = nilDateLabel;
		[nilDateLabel setHidden:YES];
	}
	else {
		saveView = dueDatePicker;
		NSPoint p = [dueDatePicker frame].origin;
		[dueDatePicker removeFromSuperview];
		[dueDatePicker setHidden:YES];
		[dueDatePicker setDateValue:[NSDate date]];
		[dueButton setIntValue:NO];
		p.y +=4;
		[nilDateLabel setFrameOrigin:p];
		[nilDateLabel setHidden:NO];
	}
}

- (void) windowDidLoad
{
	[self initGuts];
}

//- (void)  windowWillLoad
//{
//	[self initGuts];
//}

- (void) loadLists
{
	if (context.idMapping == nil){
	//	[context setCallback:@selector(listsDone)];
		[context getLists:self callback:@selector(listsDone)];
	}
	NSDictionary *map = context.idMapping;
	NSString *listId = [tdc objectForKey:@"list_id"];
	NSArray *keys = [map allKeys];
	for (int i = 0; i < [keys count]; i++){
		NSString *listName = [keys objectAtIndex:i];
		[listsCombo  addItemWithTitle:listName];
		NSString *id_ = [map objectForKey:listName];
		if ([id_ isEqualToString: listId]){
			[listsCombo selectItemWithTitle:listName];
		}
	}
}

-(void) listsDone
{
	[busyIndicator stopAnimation:self];
	[self loadLists];
}

- (void) showWindow:(id)sender
{
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[super.window makeKeyWindow];
	[super.window orderFrontRegardless];
}

-(void) handleClick: (NSDictionary*) ctx
{
	NSString *href = [ctx objectForKey:@"href"];
	NSURL *url = [NSURL URLWithString:href];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

-(void) clickSwitch:(id)sender
{
	[self disableEverything];
	currentJob = taskActionSwitch;
	[listLabel setEnabled:YES];
	[listsCombo setEnabled:YES];
}

-(TaskDialogController*)initWithWindowNibName:(NSString*)nibName andContext: (RTMProtocol*) mod andParams: (NSDictionary*) params
{	
	self = (TaskDialogController*)[super initWithWindowNibName:nibName];
	if (self){
		tdc = params;
		context = mod;
//	
//		[nameField setStringValue:[tdc objectForKey:@"name"]];
//		[notesField setStringValue:[tdc objectForKey:@"notes"]];
//		[self loadLists];
	}
	return self;
}
@end

@implementation UpdateSteps
@synthesize steps;
- (id) init
{
	if (self = [super init]) {
		steps = [NSMutableArray arrayWithCapacity:4];
		[steps addObject:[NSNumber numberWithInt:updateDone]];
	}
	return self;
}

- (void) addStep: (updateStep) step
{
	NSNumber *temp = [NSNumber numberWithInt:step];
	[steps addObject:temp];
}

- (updateStep) getStep
{
	NSNumber *temp = [steps lastObject];
	return [temp intValue];
}

- (void) popStep
{
	NSNumber *temp = [steps lastObject];
	[steps removeObject:temp];
}
@end
