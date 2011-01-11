//
//  StatsWindow.m
//  Nudge
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "StatsWindow.h"
#import "WPADelegate.h"
#import "Schema.h"

@implementation StatsWindow
@synthesize resetButton;
@synthesize summaryTable;
@synthesize workTable;
//@synthesize playText;
//@synthesize workText;
//@synthesize awayText;
@synthesize statsData;
@synthesize workData;
@synthesize statsArray;
@synthesize workArray;
- (void) clickClear: (id) sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" 
									 defaultButton:@"No" alternateButton:@"Yes" 
									   otherButton:nil 
						 informativeTextWithFormat:@"Do you want to delete all stored tracking data?\n%@ needs to quit to complete this action.  Click 'Yes' to continue.",__APPNAME__];
	[alert runModal];
	NSButton *yes = (NSButton*)[alert.buttons objectAtIndex:1];
	if (yes.state == NSOnState) {
		[(WPADelegate*)[[NSApplication sharedApplication] delegate] removeStore: self];
		[super.window close];
	}
}

//-(void) windowDidLoad
//{
//
//}
-(id) initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
	if (self)
	{
		NSLog(@"in init");
	//	[self setContents];
	}
	return self;
}

-(void) showWindow:(id)sender
{
	[self setContents];
}

-(void) windowDidLoad
{
	[self setContents];
}
- (void) setContents
{
	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	[nad newRecord:[Context sharedContext].startingState];

	statsArray = [Schema statsReportForDate:[NSDate date] inContext:nad.managedObjectContext];
	statsData = [[SummaryTable alloc]initWithRows: statsArray];
	summaryTable.dataSource = statsData;
	[summaryTable noteNumberOfRowsChanged];
	workArray = [Schema fetchWorkReportForMonth:[NSDate date] inContext:nad.managedObjectContext];
	workData = [[WorkTable alloc]initWithRows: workArray];
	workTable.dataSource = workData;
	[workTable noteNumberOfRowsChanged];
}

@end
