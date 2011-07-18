//
//  ManageProjectsController.m
//  WorkPlayAway
//
//  Created by Charles on 7/11/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "ManageProjectsController.h"
#import "WriteHandler.h"
#import "WPADelegate.h"

@implementation ManageProjectsController
@synthesize addCell, removeCell, projList, projectsTable;
- (void) showWindow:(id)sender
{
	WPADelegate *del = (WPADelegate*)[[NSApplication sharedApplication]delegate];
	WriteHandler *wh = [del ioHandler];
	[projList setManagedObjectContext: [wh managedObjectContext]];
	[projList setFetchPredicate:[NSPredicate predicateWithFormat:@"retireTime == nil"]];
	[projList fetch: self];
}

- (IBAction) clickAdd: (id) sender
{
	AddProjectController *apC = [[AddProjectController alloc] initWithWindowNibName:@"AddProject"];
	[apC showWindow:self];
	[[apC window] orderFrontRegardless];
	[NSApp runModalForWindow: [apC window]];
	[projList fetch:self];
}

- (IBAction) clickRetire: (id) sender 
{
	NSError *error = nil;
	NSManagedObject *proj = [[projList selectedObjects] objectAtIndex:0];
	NSString *name = [proj valueForKey:@"name"];
	if ([name isEqualToString:@"Uncategorized"])
		return;
	[proj setValue:[NSDate date] forKey:@"retireTime"];
	[[projList managedObjectContext]processPendingChanges];
	[[projList managedObjectContext] save:&error];
	[projList fetch:self];
}

@end
@implementation AddProjectController
@synthesize name, notes;

- (IBAction) clickOk: (id) sender {
	NSString *nameStr = [name stringValue];
	NSString *notesStr = [notes stringValue];
	[WriteHandler sendCreateNewProject:nameStr notes:notesStr];
	[self clickCancel:self];
}
- (IBAction) clickCancel: (id) sender {
	[NSApp stopModal];
	[[self window] close];
}

@end
