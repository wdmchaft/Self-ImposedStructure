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

@implementation TaskDialogController
@synthesize busyIndicator;
@synthesize dismissButton;
@synthesize context;
@synthesize tlHandler;
@synthesize nameField;
@synthesize notesField;
@synthesize dueDatePicker;
@synthesize listsCombo;
@synthesize tdc;
@synthesize currentJob;

-(void) clickDismiss: (id) sender
{
	currentJob = JOB_NONE;
}

- (void) clickOk: (id) sender
{
	if (currentJob != JOB_NONE){
	//	[context setCallback: @selector(timelineDone)];
		[context timelineRequest:self callback:@selector(timelineDone)];
	}
	else {
		[self close];
	}
}

- (void) clickUpdate: (id) sender
{
	currentJob = JOB_MOVETO;
}

- (void) clickCancel: (id) sender
{ 
	[self close];
}


-(void) clickComplete: (id) sender
{
	currentJob = JOB_COMPLETE;
}

-(void) clickDelete: (id) sender
{
	currentJob = JOB_DELETE;	
}


-(void) timelineDone
{

	if (![context timelineStr]){
		
		[BaseInstance sendErrorToHandler:context.handler 
								   error:@"No time line received" 
								  module:[context.module description]]; 
		NSLog(@"oops -- bad");
	}
	else 
	{
		if (currentJob == JOB_DELETE)
		{
			[self sendDelete];
		} 
		else if (currentJob == JOB_COMPLETE) 
		{
			[self sendComplete];
		} 
		else // currentJob == JOB_MOVETO 
		{ 
		//	[context setCallback:@selector(rmDone)];
			NSString *newListName = [listsCombo stringValue];
			NSString *newListId = [context.idMapping objectForKey: newListName];			
			[context sendMoveTo:self callback:@selector(rmDone) list: newListId params:tdc];
		}
	}
}



- (void) sendDelete
{
//	[context setCallback:@selector(rmDone)];
	[context sendRm: self callback:@selector(rmDone) methodName: @"rtm.tasks.delete" params:tdc];
}

- (void) sendComplete
{
//	[context setCallback:@selector(rmDone)];
	[context sendRm: self callback:@selector(rmDone) methodName:@"rtm.tasks.complete" params: tdc];
}

- (void) rmDone
{
	[busyIndicator stopAnimation:self];
	[NSAlert alertWithMessageText:@"Completed!" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"yippie!"];
	[self close];
}

- (void)windowWillLoad
{
	[nameField setStringValue:[tdc valueForKey:@"name"]];
	[notesField setStringValue:[tdc valueForKey:@"notes"]];
	[self loadLists];
	currentJob = JOB_NONE;
	
}

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
		NSString *taskName = [keys objectAtIndex:i];
		[listsCombo addItemWithObjectValue:taskName];
		NSString *id = [map objectForKey:taskName];
		if ([id isEqualToString: listId]){
			[listsCombo setStringValue:taskName];
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

- (void) windowDidLoad
{
	[nameField setStringValue:[tdc objectForKey:@"name"]];
	if ([tdc objectForKey:@"notes"]){
		[notesField setStringValue:[tdc objectForKey:@"notes"]];
 	}
	[self loadLists];
}

-(void) handleClick: (NSDictionary*) ctx
{
	NSString *href = [ctx objectForKey:@"href"];
	NSURL *url = [NSURL URLWithString:href];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

-(void) listChanged:(id)sender
{
	[self clickUpdate:self];
}

-(TaskDialogController*)initWithWindowNibName:(NSString*)nibName andContext: (RTMProtocol*) mod andParams: (NSDictionary*) params
{	
	self = (TaskDialogController*)[super initWithWindowNibName:nibName];
	if (self){
		tdc = params;
		context = mod;
	
		[nameField setStringValue:[tdc objectForKey:@"name"]];
		[notesField setStringValue:[tdc objectForKey:@"notes"]];
		[self loadLists];
	}
	return self;
}


@end
