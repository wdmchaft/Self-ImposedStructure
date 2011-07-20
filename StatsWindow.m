//
//  StatsWindow.m
//  Self-Imposed Structure
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "StatsWindow.h"

#import "SummaryStatusViewController.h"
#import "GoalsViewController.h"
#import "ActivitiesViewController.h"
#import "TodosViewController.h"

@implementation StatsWindow
@synthesize tabView;
@synthesize tabViewsTable;

- (void) initTabs{
	NSTabViewItem *item = [tabView selectedTabViewItem];
	NSLog(@"initTabs item = %@", item);
	[self tabView: tabView willSelectTabViewItem: item];
	[self tabView: tabView didSelectTabViewItem: item];
}

- (void) awakeFromNib
{
	NSLog(@"awakeFromNib");
	[super awakeFromNib];
	LoadableMeta *summary = [[LoadableMeta alloc] initWithId: @"Summary" 
														view: @"SummaryStatusViewController"
												  controller: [SummaryStatusViewController class]];
	
	LoadableMeta *goals = [[LoadableMeta alloc] initWithId: @"Goals" 
													  view: @"GoalsView"
												controller: [GoalsViewController class]];
	
	LoadableMeta *activities = [[LoadableMeta alloc] initWithId: @"Activities" 
														   view: @"ActivityView"
													 controller: [ActivitiesViewController class]];
	
	LoadableMeta *todos = [[LoadableMeta alloc] initWithId: @"Todos" 
													  view: @"TodosView"
												controller: [TodosViewController class]];
	
	tabViewsTable = [NSDictionary dictionaryWithObjectsAndKeys:
					summary, [summary identifier],
					goals, [goals identifier],
					activities, [activities identifier],
					todos, [todos identifier], 
					 nil];
	[self initTabs];
}

- (id) initWithWindowNibName:(NSString*) nibName
{
	NSLog(@"initWithWindowNibName:%@", nibName);
	if ([super initWithWindowNibName:nibName]){
		[self initTabs];
	}
	return self;
}
- (id) initWithWindow:(NSWindow *)window
{
	NSLog(@"initWithWindow:%@", window);
	if ([super initWithWindow:window]){
		[self initTabs];
	}
	return self;
}

- (void) windowDidLoad
{
	NSLog(@"windowDidLoad");
	[super windowDidLoad];
}

- (void) showWindow:(id)sender
{
	NSLog(@"showWindow:@%", sender);
	[super showWindow:self];
	[self initTabs];
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSLog(@"willSelectTabViewItem: %@", tabViewItem);
	
	LoadableMeta *lm = [tabViewsTable objectForKey: [tabViewItem identifier]];
	if ([lm ctrl] == nil) {
		Class cClass = [lm controlClass];
		RefreshableViewController *ctrl = [[cClass alloc]initWithNibName:[lm viewName] bundle:nil];
		[lm setCtrl: ctrl];
		[tabViewItem setView:[ctrl view]];
	}
	
	[[lm ctrl] refreshView];
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSLog(@"shouldSelectTabViewItem: %@", tabViewItem);
	
	return YES;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSLog(@"didSelectTabViewItem: %@", tabViewItem);
	
}

@end

@implementation LoadableMeta
@synthesize identifier, viewName, controlClass, ctrl;
- (id) initWithId: (NSString*) idStr view: (NSString*) vName controller: (Class) cClass
{
	self = [super init];
	if (self)
	{
		identifier = idStr;
		viewName = vName;
		controlClass = cClass;
	}
	return self;
}
@end