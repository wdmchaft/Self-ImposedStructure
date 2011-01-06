//
//  StatsWindow.m
//  Nudge
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "StatsWindow.h"
#import "WPADelegate.h"


@implementation StatsWindow
@synthesize resetButton;
@synthesize detailTable;
@synthesize playText;
@synthesize workText;
@synthesize awayText;

- (void) clickClear: (id) sender
{
	[(WPADelegate*)[[NSApplication sharedApplication] delegate] removeStore: self];
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
		[self setContents];
	}
	return self;
}

-(void) showWindow:(id)sender
{
	[self setContents];
}
- (void) setContents
{
	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	[nad newRecord:[Context sharedContext].startingState];
	double val = [nad countEntity:@"Work" inContext:nad.managedObjectContext];
	[workText setStringValue:[NSString stringWithFormat:@"%f",val]];
	[workText setNeedsDisplay];
	NSLog(@"work %f", val);
	val = [nad countEntity:@"Away" inContext:nad.managedObjectContext];
	[awayText setStringValue:[NSString stringWithFormat:@"%f",val]];	
	[awayText setNeedsDisplay];
	NSLog(@"away %f", val);
	val = [nad countEntity:@"Free" inContext:nad.managedObjectContext];
	[playText setStringValue:[NSString stringWithFormat:@"%f",val]];	
	[playText setNeedsDisplay];
	NSLog(@"play %f", val);
}
@end
