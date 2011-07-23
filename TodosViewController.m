//
//  TodosViewController.m
//  WorkPlayAway
//
//  Created by Charles on 7/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "TodosViewController.h"
#import "WPADelegate.h"

@implementation TodosViewController
@synthesize tasksTable, prog, data;


- (void) refreshView
{
	NSDate *starting = [NSDate dateWithTimeIntervalSinceNow:-(14*24*60*60)];
//	NSDate *ending = [NSDate date];
	WPADelegate *nad = (WPADelegate*) [NSApplication sharedApplication].delegate;
	[data setManagedObjectContext:[nad managedObjectContext]];
	NSPredicate *predicate =
	[NSPredicate predicateWithFormat:@"endTime >= %@", starting];
	[data setFilterPredicate:predicate];
	//[data reload];
	[data performSelectorInBackground:@selector(fetch:) withObject:self];
	
}

@end
