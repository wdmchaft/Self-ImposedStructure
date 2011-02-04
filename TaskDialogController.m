//
//  TaskDialogController.m
//  RTGTest
//
//  Created by Charles on 11/6/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//
#import "Secret.h"
#import "Context.h"
#import "TaskDialogController.h"
#import "RequestREST.h"
//#import "RTGTestAppDelegate.h"
#import "CompleteRespHandler.h"
#import "ListsHandler.h"
#import "BaseInstance.h"

@implementation TaskDialogController
@synthesize busyIndicator;
@synthesize dismissButton;
@synthesize timelineStr;
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
	if ([[dismissButton title] isEqualToString: @"Update"]){
		currentJob = JOB_MOVETO;
		[self timelineRequest];
	}
	[self close];
}
- (void) timelineRequest
{
	
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									context.tokenStr, @"auth_token",
									@"rtm.timelines.create", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	tlHandler = (TimelineHandler*)[[TimelineHandler alloc]initWithHandler:self]; 
	[busyIndicator startAnimation:self];
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: tlHandler];
	[rr release];
	
}
-(void) clickComplete: (id) sender
{
	currentJob = JOB_COMPLETE;
	[self timelineRequest];

}

-(void) clickDelete: (id) sender
{
	currentJob = JOB_DELETE;
	[self timelineRequest];
	
}

- (void) sendMoveTo: (NSString*) newList
{
	//	RTGTestAppDelegate *delegate = (<NSApplicationDelegate>)[NSApplication sharedApplication];
	//	context = [delegate context];
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									context.tokenStr, @"auth_token",
									@"rtm.tasks.moveTo", @"method",
									newList,@"to_list_id",
									[tdc objectForKey:@"task_id"], @"task_id",
									[tdc objectForKey:@"taskseries_id"], @"taskseries_id",
									[tdc objectForKey:@"list_id"], @"from_list_id",
									[tlHandler timeLine], @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *handler = (CompleteRespHandler*)[[CompleteRespHandler alloc]initWithHandler:self]; 
	[busyIndicator startAnimation:self];
	
	context.timelineStr = nil; // we are about to fetch a new time line
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: handler];
	[rr release];
	
}

-(void) timelineDone
{

	if (![tlHandler timeLine]){
		
		[BaseInstance sendErrorToHandler:context.handler 
								   error:@"No time line received" 
								  module:[context description]]; 
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
			NSString *newListName = [listsCombo stringValue];
			NSString *newListId = [context.idMapping objectForKey: newListName];			
			[self sendMoveTo:newListId];
		}
	}
}

- (void) sendRm: (NSString*) method
{
//	RTGTestAppDelegate *delegate = (<NSApplicationDelegate>)[NSApplication sharedApplication];
//	context = [delegate context];
	RequestREST *rr = [[RequestREST alloc]init];
	NSLog(@"auth %@\n task %@\n series %@\n list %@\n api %@",[tdc objectForKey:@"auth_token"],
		  [tdc objectForKey:@"task_id"],
		  [tdc objectForKey:@"taskseries_id"], 
		  [tdc objectForKey:@"list_id"],
		  [tdc objectForKey:@"api_key"],nil);
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									context.tokenStr, @"auth_token",
									method, @"method",
									[tdc objectForKey:@"task_id"], @"task_id",
									[tdc objectForKey:@"taskseries_id"], @"taskseries_id",
									[tdc objectForKey:@"list_id"], @"list_id",
									[tlHandler timeLine], @"timeline",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	CompleteRespHandler *handler = (CompleteRespHandler*)[[CompleteRespHandler alloc]initWithHandler:self]; 
	[busyIndicator startAnimation:self];
	
	context.timelineStr = nil; // we are about to fetch a new time line
	
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET
										 andParams:params]
				andHandler: handler];
	[rr release];
	
}

- (void) sendDelete
{
	[self sendRm: @"rtm.tasks.delete"];
}

- (void) sendComplete
{
	[self sendRm: @"rtm.tasks.complete"];
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
	
}

- (void) loadLists
{
	if (context.idMapping == nil){
		[self getLists];
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


-(void) getLists
{
	RequestREST *rr = [[RequestREST alloc]init];
	NSMutableDictionary *params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
									context.tokenStr, @"auth_token",
									@"rtm.lists.getList", @"method",
									@"xml", @"format",
									APIKEY, @"api_key", nil];
	
	ListsHandler *listsHandler = (ListsHandler*)[[ListsHandler alloc]initWithContext:context andDelegate:self]; 
	[busyIndicator startAnimation:self];
	[rr sendRequestWithURL:[rr createURLWithFamily:@"rest" 
									   usingSecret:SECRET 
										 andParams:params]
				andHandler: listsHandler];
	[rr release];
}
-(void) listsDone
{
	[busyIndicator stopAnimation:self];
	[self loadLists];
}
//NSWindow
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
	[dismissButton setTitle:@"Update"];
	currentJob = JOB_MOVETO;
}

-(TaskDialogController*)initWithWindowNibName:(NSString*)nibName andContext: (RTMModule*) mod andParams: (NSDictionary*) params
{	
	self = (TaskDialogController*)[super initWithWindowNibName:nibName];
	if (self){
		self.tdc = params;
		self.context = mod;
	
		[nameField setStringValue:[tdc objectForKey:@"name"]];
		[notesField setStringValue:[tdc objectForKey:@"notes"]];
		[self loadLists];
	}
	return self;
}
@end
