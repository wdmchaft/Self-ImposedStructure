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

@implementation TaskDialogController
@synthesize busyIndicator;
@synthesize dueButton;
@synthesize context;
@synthesize tlHandler;
@synthesize nameField;
@synthesize notesField;
@synthesize dueDatePicker;
@synthesize listsCombo;
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
	NSString *taskNote = [tdc objectForKey:@"note"];
	NSString *newNote = [notesField stringValue];
	if ([newNote length] == 0) newNote == nil;
	
	if (taskNote && newNote && ![[notesField stringValue] isEqualToString: taskNote])
		[updateSteps addStep: updateNote];	
	else if (taskNote != newNote)
		[updateSteps addStep: updateNote];	

	NSDate *taskDate = [tdc objectForKey:@"due_time"];
	if ([dueButton intValue]) {
		if (taskDate ==  nil) {
			[updateSteps addStep:updateDate];
		}
		if (![taskDate isEqualToDate:[dueDatePicker dateValue]]) {
			[updateSteps addStep: updateDate];
		}
	}
	else {
		if (taskDate !=  nil) {
			[updateSteps addStep:updateDate];
		}
	}
	
}

- (void) clickOk: (id) sender
{
	// decide what to do
	switch (currentJob) {
		case taskActionSwitch:
			NSLog(@"switch");
			break;
			
		case taskActionModify:
			[self setSteps];
			NSLog(@"modify");
			break;
		case taskActionDelete:
			NSLog(@"delete");	
			break;
		case taskActionComplete:
			NSLog(@"complete");
			break;
			
		default:
			break;
	}
	[context timelineRequest:self callback:@selector(timelineDone)];
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

- (void) handleDate
{
	
}
- (void) stepDone
{
	[updateSteps popStep];
	[context timelineRequest:self callback:@selector(timelineDone)];
}

- (void) sendName
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	[newDict setObject:[nameField stringValue] forKey:@"name"];
	[context send: self 
		 callback:@selector(stepDone) 
	   methodName: @"rtm.tasks.setName" 
		   params:newDict 
	  optionNames:[NSArray arrayWithObject:@"name"]];	
}

- (void) sendNote
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	NSString *newText = [notesField stringValue];
	[newDict setObject:[notesField stringValue] forKey:@"note_text"];
	NSString *oldText = [tdc objectForKey:@"note_text"]; 
	NSString *method = @"rtm.tasks.notes.edit";
	if (!oldText) {
		method = @"rtm.tasks.notes.add";
	} 
	if ([newText length] == 0){
		method = @"rtm.tasks.notes.delete";
	}
	
	NSString *title =  oldText ?[tdc objectForKey:@"note_title"] : @"";
	[newDict setObject:title forKey:@"note_title"];
	[context send: self 
		 callback:@selector(stepDone) 
	   methodName: method 
		   params:newDict 
	  optionNames:[NSArray arrayWithObjects:@"note_id", @"note_title", @"note_text",nil]];	
}

- (void) sendDate
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tdc];
	int val = [dueButton intValue];
	BOOL hasDate = val != 0;
	[newDict setObject:[NSNumber numberWithBool:hasDate] forKey:@"has_due_time"];
	if (hasDate){
		NSDate *newDate = [dueDatePicker dateValue];
		NSDateFormatter *inputFormatter = [NSDateFormatter new];
     	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [inputFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];  
		NSString *newDateStr = [inputFormatter stringFromDate:newDate];
		[newDict setObject:newDateStr forKey:@"due"];
	} 
	[context send: self 
		 callback:@selector(stepDone) 
	   methodName: @"rtm.tasks.setDueDate" 
		   params:newDict 
	  optionNames:[NSArray arrayWithObjects:@"due", @"has_due_time", nil]];	
}


-(void) timelineDone
{

	if (![context timelineStr]){
		
		[BaseInstance sendErrorToHandler:context.handler 
								   error:@"No time line received" 
								  module:[context.module description]]; 
		//NSLog(@"oops -- bad");
	}
	else 
	{
		if (currentJob == taskActionDelete)
		{
			[self sendDelete];
		} 
		else if (currentJob == taskActionComplete) 
		{
			[self sendComplete];
		} 
		else if (currentJob == taskActionSwitch)
		{ 
		//	[context setCallback:@selector(simpleDone)];
			NSString *newListName = [listsCombo titleOfSelectedItem];
			NSString *newListId = [context.idMapping objectForKey: newListName];			
			[context sendMoveTo:self callback:@selector(simpleDone) list: newListId params:tdc];
		}
		else if (currentJob == taskActionModify)
		{
			updateStep step = [updateSteps getStep];
			switch (step) {
				case updateDone:
					[self clickCancel:self];
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
				default:
					break;
			}
		}
	}
}

- (void) sendDelete
{
	[context sendSimple: self callback:@selector(simpleDone) methodName: @"rtm.tasks.delete" params:tdc];
}

- (void) sendComplete
{
//	[context setCallback:@selector(simpleDone)];
	[context sendSimple: self callback:@selector(simpleDone) methodName:@"rtm.tasks.complete" params: tdc];
}

- (void) simpleDone
{
	[busyIndicator stopAnimation:self];
	[NSAlert alertWithMessageText:@"Completed!" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"yippie!"];
	[self close];
}

- (void) initGuts
{
	[self disableEverything];
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
