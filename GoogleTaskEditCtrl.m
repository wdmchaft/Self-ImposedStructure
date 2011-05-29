//
//  GoogleTaskEditCtrl.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/22/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "GoogleTaskEditCtrl.h"

@implementation GoogleTaskEditCtrl
@synthesize buttonsMatrix;
@synthesize titleLabel;
@synthesize notesLabel;
@synthesize listLabel;
@synthesize listDropDown;
@synthesize titleEdit;
@synthesize datePicker;
@synthesize dueToggle;
@synthesize prog;
@synthesize protocol;
@synthesize task;
@synthesize notesEdit;
@synthesize okAction;
@synthesize nilDateLabel;
@synthesize saveView;
@synthesize baseView;
@synthesize newListId;


- (void) loadLists
{
	if (protocol.idMapping == nil){
		//	[context setCallback:@selector(listsDone)];
		[protocol getLists:self returnTo:@selector(listsDone)];
	}
	NSDictionary *map = protocol.idMapping;
	NSString *listId = [task objectForKey:@"id"];
	NSArray *keys = [map allKeys];
	for (int i = 0; i < [keys count]; i++){
		NSString *listName = [keys objectAtIndex:i];
		NSDictionary *listInfo = [map objectForKey:listName];
		NSString *id_ = [listInfo objectForKey:@"id"];
		[listDropDown addItemWithTitle:listName];
		if ([id_ isEqualToString: listId]){
			[listDropDown setStringValue:listName];
		}
	}
}

- (void) allDone
{
	[prog stopAnimation:self];
	[prog setHidden:YES];
	[self close];
}
- (void) actionComplete
{
	[self allDone];
}

- (void) deleteDone
{
	[protocol sendAdd:self returnTo:@selector(createComplete) params:task listId: newListId];
}

- (void) createComplete
{
	[self allDone];
}

- (void) updateComplete
{
	[self allDone];
}

- (void) gtProtocol: (GTProtocol*) proto callEndingAt: (SelWrapper*) selWrap gotError:  (NSError*) error  
{
	[prog stopAnimation:self];
	[prog setHidden:YES];
	NSLog(@"error: %@", error);
	SEL returnAddr = selWrap.selector;
	NSString *msg;
	if (returnAddr == @selector(actionComplete)){
		msg = @"error completing task";
	}
	if (returnAddr == @selector(deleteComplete)){
		msg = @"error deleting task";
	}
	if (returnAddr == @selector(deleteDone)){
		msg = @"error doing delete for switch list";
	}
	if (returnAddr == @selector(createComplete)){
		msg = @"error doing create for switch list";
	}
	if (returnAddr == @selector(updateComplete)){
		msg = @"error updating task";
	}
	NSAlert *alert = [NSAlert alertWithMessageText:@"Problem with Action"
									 defaultButton:nil 
								   alternateButton:nil 
									   otherButton:nil 
						 informativeTextWithFormat:msg];
	[alert runModal];
}

- (NSString*) stringFor:(NSDate*) inDate
{
	return [[protocol dateFormatter]stringFromDate:inDate];
}

- (void) clickOK: (id) sender
{
	NSMutableDictionary *taskUpdates = [NSMutableDictionary dictionaryWithCapacity:2];
	NSDictionary *newList;
	NSString *newListStr = @"";
	[prog setHidden:NO];
	[prog startAnimation:self];
	switch (okAction) {
		case taskActionComplete:
			[protocol sendComplete:self returnTo:@selector(actionComplete) params:task];
			break;
		case taskActionDelete:
			[protocol sendDelete:self returnTo:@selector(deleteComplete) params:task];
			break;
		case taskActionSwitch:
			newListStr = [listDropDown titleOfSelectedItem];
			newList = [[protocol idMapping] objectForKey:newListStr]; 
			newListId = [newList objectForKey:@"id"];
			[protocol sendDelete:self returnTo:@selector(deleteDone) params:task];
			break;
		case taskActionModify:
			[taskUpdates setObject: [task objectForKey:@"id"] forKey:@"id"] ;
			[taskUpdates setObject: [task objectForKey:@"selfLink"] forKey:@"selfLink"] ;
			[taskUpdates setObject: [titleEdit stringValue] forKey:@"title"] ;
			[taskUpdates setObject: [notesEdit stringValue] forKey:@"notes"] ;
			if ([dueToggle intValue]){
				[taskUpdates setObject:[self stringFor:[datePicker dateValue]] forKey:@"due"];
			}
			else {
				[taskUpdates setObject:@"nil" forKey:@"due"];
			}
			[protocol sendUpdate:self returnTo:@selector(updateComplete) params:taskUpdates];
			break;
		default:
			break;
	}
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

- (NSDate*) dateFor: (NSString*) dateStr
{
	return [[protocol dateFormatter] dateFromString:dateStr];
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
	[dueToggle setEnabled:YES];
	NSString *dateStr = [task objectForKey:@"due"];
	if (dateStr){
		[datePicker setEnabled:YES];
		[datePicker setHidden:NO];
		[datePicker setDateValue:[self dateFor:dateStr]];
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

- (void) initGuts
{
	okAction = taskActionComplete;
	[self disableEverything];
	[prog setHidden:YES];
	[titleEdit setStringValue:[task valueForKey:@"name"]];
	NSString *notes = [task valueForKey:@"notes"];
	if (notes){
		[notesEdit setStringValue:notes];
	}
	[buttonsMatrix setState:YES atRow:0 column:0];
	NSString *dueStr = [task objectForKey:@"due"];
	if (dueStr){
		[datePicker setHidden:NO];
		[dueToggle setIntValue:YES];
		[datePicker setDateValue:[self dateFor:dueStr]];
		saveView = nilDateLabel;
		[nilDateLabel setHidden:YES];
	}
	else {
		saveView = datePicker;
		NSPoint p = [datePicker frame].origin;
		[datePicker removeFromSuperview];
		[datePicker setHidden:YES];
		[datePicker setDateValue:[self dateFor:dueStr]];
		[dueToggle setIntValue:NO];
		p.y +=4;
		[nilDateLabel setFrameOrigin:p];
		[nilDateLabel setHidden:NO];
		
	}
	[self loadLists];
}

- (void)windowWillLoad
{
	[self initGuts];
}



-(void) listsDone
{
	[prog stopAnimation:self];
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


-(id)initWithWindowNibName:(NSString*)nibName usingProtocol: (GTProtocol*) mod forTask: (NSDictionary*) params
{	
	self = [super initWithWindowNibName:nibName];
	if (self){
		task = [NSMutableDictionary dictionaryWithDictionary:params];
		protocol = mod;
		[self initGuts];
	}
	return self;
}

@end
