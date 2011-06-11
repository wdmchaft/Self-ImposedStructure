//
//  ICalTodoEdit.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "ICalTodoEdit.h"
#import "BaseTaskList.h"
#import "iCal.h"

@implementation ICalTodoEdit
@synthesize buttonsMatrix;
@synthesize titleLabel;
@synthesize notesLabel;
@synthesize listLabel;
@synthesize listDropDown;
@synthesize priorityDropDown;
@synthesize titleEdit;
@synthesize datePicker;
@synthesize dueToggle;
@synthesize prog;
@synthesize task;
@synthesize notesEdit;
@synthesize okAction;
@synthesize nilDateLabel;
@synthesize saveView;
@synthesize baseView;
@synthesize newListId;
@synthesize completeQueue;
@synthesize modName;
@synthesize calendarName;
@synthesize todoItem;
@synthesize iCalApp;

#define P0 @"tdp0"
#define P1 @"tdp9"
#define P2 @"tdp5"
#define P3 @"tdp1"

- (void) loadLists
{
	for ( iCalCalendar *cal in iCalApp.calendars){
		[listDropDown addItemWithTitle:cal.name];
    }
	[listDropDown selectItemWithTitle:calendarName];
	//[listDropDown setStringValue: calendarName];
}

- (void) allDone
{
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center postNotificationName: completeQueue 
						  object: nil 
						userInfo: [NSDictionary dictionaryWithObject:modName forKey:@"module"]];
	[prog stopAnimation:self];
	[prog setHidden:YES];
	[self close];
}

- (void) actionComplete
{
	NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
	NSDictionary *taskInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [todoItem summary], @"task",
							  modName, @"project",
							  modName, @"source",
							  nil];
	[dnc postNotificationName:completeQueue object:nil userInfo: taskInfo];
}


- (void) doModify
{
	NSString *newNote = [notesEdit stringValue];
	if ([newNote length] == 0) newNote = nil;
	NSString *oldNote = [todoItem objectDescription];
	if (newNote != oldNote){
		[todoItem setObjectDescription:newNote];
	}
	NSString *newName = [titleEdit stringValue];
	if (![newName isEqualToString: [todoItem summary]]){
		[todoItem setSummary:newName];
	}
	switch ([priorityDropDown indexOfSelectedItem]) {
		case 0:
			[todoItem setPriority:iCalCALPrioritiesNoPriority];
			break;
		case 1:
			[todoItem setPriority:iCalCALPrioritiesLowPriority];
			break;
		case 2:
			[todoItem setPriority:iCalCALPrioritiesMediumPriority];
			break;
		case 3:
			[todoItem setPriority:iCalCALPrioritiesHighPriority];
			break;
		default:
			break;
	}
	if ([dueToggle intValue]) {
		[todoItem setDueDate:[datePicker dateValue]];
	}
	else {
		[todoItem setDueDate:nil];
	}
}

- (void) doSwitch
{
	NSString *newListStr = [listDropDown titleOfSelectedItem];
	iCalCalendar *newCal = [[iCalApp calendars] objectWithName:newListStr];
	
	NSDictionary *props = [NSDictionary dictionaryWithObjectsAndKeys:
	 [todoItem summary], @"summary",
	 nil];
	
	// create the new todo 
	
	iCalTodo *newItem = [[[iCalApp classForScriptingClass:@"todo"] alloc]
				initWithProperties: props];
	// add it to the list of todos for this calendar. (must be before setting properties)
	[[newCal todos] addObject: newItem];

	[newItem setObjectDescription:[todoItem objectDescription]];
	[newItem setDueDate:[todoItem dueDate]];
	iCalCALPriorities priority = [todoItem priority];
	[newItem setPriority:priority];
	
	
	[todoItem delete];
}

- (void) clickOK: (id) sender
{
	[prog setHidden:NO];
	[prog startAnimation:self];
	switch (okAction) {
		case taskActionComplete:
			[todoItem setCompletionDate:[NSDate date]];
			[self actionComplete];
			break;
		case taskActionDelete:
			[todoItem delete];
			break;
		case taskActionSwitch:
			[self doSwitch];
			break;
		case taskActionModify:
			[self doModify];
			break;
		default:
			break;
	}

	[self allDone];
}

- (void) clickCancel: (id) sender
{ 
	[self close];
}


- (void) disableEverything
{
	[titleEdit setEditable:NO];
	[titleEdit setEnabled:NO];
	[notesEdit setEditable:NO];
	[notesEdit setEnabled:NO];
	[datePicker setEnabled:NO];
	[dueToggle setEnabled:NO];
	[listLabel setEnabled:NO];
	[titleLabel setEnabled:NO];
	[notesLabel setEnabled:NO];
	[listDropDown setEnabled:NO];
	[priorityDropDown setEnabled:NO];
}

-(void) clickComplete: (id) sender
{
	[self disableEverything];
	okAction = taskActionComplete;
}

-(void) clickDelete: (id) sender
{
	[self disableEverything];
	okAction = taskActionDelete;
}


- (void) clickModify: (id) sender
{
	[self disableEverything];
	okAction = taskActionModify;
	[notesEdit setEnabled:YES];
	[notesEdit setEditable:YES];
	[titleEdit setEnabled:YES];
	[titleEdit setEditable:YES];
	[titleLabel setEnabled:YES];
	[notesLabel setEnabled:YES];
	[priorityDropDown setEnabled:YES];
	[dueToggle setEnabled:YES];
	NSDate *date = [todoItem dueDate];
	if (date){
		[datePicker setEnabled:YES];
		[datePicker setHidden:NO];
		[datePicker setDateValue:date];
	}
}

-(void) clickSwitch: (id) sender
{
	[self disableEverything];
	okAction = taskActionSwitch;
	[listLabel setEnabled:YES];
	[listDropDown setEnabled:YES];
}

- (void) setDateOrNil:(NSDate*) dateVal
{
	NSPoint p;
	if (!dateVal){
		saveView = datePicker;
		p = [datePicker frame].origin;
		[datePicker setHidden:YES];
		[datePicker removeFromSuperview];
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
		[baseView addSubview:datePicker];
		p.y -= 4;
		[datePicker setFrameOrigin:p];
		[datePicker setHidden:NO];
		[datePicker setEnabled:YES];
		[datePicker setDateValue:dateVal];
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

- (IBAction) listChanged: (id) sender{
	[buttonsMatrix setEnabled:NO];
}

- (IBAction) dateChanged: (id) sender{
	[buttonsMatrix setEnabled:NO];
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
	[buttonsMatrix setEnabled:NO];
	return YES;
}

- (void) setPriorityDD 
{
	iCalCALPriorities priority = [todoItem priority];
	switch (priority) {
		case iCalCALPrioritiesNoPriority:
			[priorityDropDown selectItemAtIndex:0];
			break;
		case iCalCALPrioritiesLowPriority:
			[priorityDropDown selectItemAtIndex:1];
			break;
		case iCalCALPrioritiesMediumPriority:
			[priorityDropDown selectItemAtIndex:2];
			break;
		case iCalCALPrioritiesHighPriority:
			[priorityDropDown selectItemAtIndex:3];
			break;
		default:
			break;
	}
}

- (void) initGuts
{
	NSString *idStr = [task objectForKey:@"id"];
	iCalApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.ical"];
	if (!iCalApp){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Can not attach to iCal" 
										 defaultButton:nil alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"This is definitely not expected"];
		[alert runModal];
		[[self window] close];
	}
	iCalCalendar *cal = [[iCalApp calendars] objectWithName:calendarName];
	todoItem = [[cal todos] objectWithID:idStr];
	
	if (!todoItem){
		NSAlert *alert = [NSAlert alertWithMessageText:@"Todo item does not exist." 
										 defaultButton:nil alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"This is definitely not expected."];
		[alert runModal];
		[[self window] close];	
	}
	okAction = taskActionComplete;
	[self disableEverything];
	[prog setHidden:YES];
	NSString *title = [todoItem summary] ? [todoItem summary] : @"";
	[titleEdit setStringValue:title];
	NSString *notes = [todoItem objectDescription];
	if (notes){
		[notesEdit setStringValue:notes];
	}
	[buttonsMatrix setState:YES atRow:0 column:0];
	NSDate *due = [todoItem dueDate];
	if (due){
		[datePicker setHidden:NO];
		[dueToggle setIntValue:YES];
		[datePicker setDateValue:due];
		saveView = nilDateLabel;
		[nilDateLabel setHidden:YES];
	}
	else {
		saveView = datePicker;
		NSPoint p = [datePicker frame].origin;
		[datePicker removeFromSuperview];
		[datePicker setHidden:YES];
		[dueToggle setIntValue:NO];
		p.y +=4;
		[nilDateLabel setFrameOrigin:p];
		[nilDateLabel setHidden:NO];
		
	}
	[self setPriorityDD];
	[self loadLists];
}

- (void) showWindow:(id)sender
{
	[super.window makeKeyWindow];
	[super.window orderFrontRegardless];
}

- (void) windowDidLoad
{
	[self initGuts];
}


-(id)initWithWindowNibName: (NSString*) nibName 
			 forModuleName: (NSString*) name
			 forCalendarName: (NSString*) calName
				   forTask: (NSDictionary*) params
				usingQueue: (NSString*) queueName
{	
	self = [super initWithWindowNibName:nibName];
	if (self){
		task = [NSMutableDictionary dictionaryWithDictionary:params];
		[self setCompleteQueue: queueName];
		[self setModName: name];
		[self setCalendarName:calName];
		[self initGuts];
	}
	return self;
}

@end
