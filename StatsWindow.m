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
@synthesize detailTable;
@synthesize playText;
@synthesize workText;
@synthesize awayText;
@synthesize statsData;
@synthesize statsArray;

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
	[Schema newRecord:[Context sharedContext].startingState];
	double val = [Schema countEntity:@"Work" inContext:nad.managedObjectContext];
	[workText setStringValue:[[NSString alloc] initWithFormat:@"%f",val]];
	[workText setNeedsDisplay];
	NSLog(@"work %f", val);
	val = [Schema countEntity:@"Away" inContext:nad.managedObjectContext];
	[awayText setStringValue:[[NSString alloc] initWithFormat:@"%f",val]];	
	[awayText setNeedsDisplay];
	NSLog(@"away %f", val);
	val = [Schema countEntity:@"Free" inContext:nad.managedObjectContext];
	[playText setStringValue:[[NSString alloc] initWithFormat:@"%f",val]];	
	[playText setNeedsDisplay];
	NSLog(@"play %f", val);
	statsArray = [Schema statsReportForDate:[NSDate date] inContext:nad.managedObjectContext];
	statsData = [[StatsTable alloc]initWithData: statsArray];
	detailTable.dataSource = statsData;
	[detailTable noteNumberOfRowsChanged];
}

@end
