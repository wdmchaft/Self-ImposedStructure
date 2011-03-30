//
//  GmailModule.m
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "TestTaskModule.h"
#import "Note.h"

#define REFRESH @"Refresh"

@implementation TestTaskModule

@synthesize frequencyField;
@synthesize stepper;
@synthesize allTasks;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic refreshInterval;
@dynamic enabled;
@dynamic category;
@dynamic name;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		name =@"Test Tasks";
		notificationName = @"Mail Alert";
		notificationTitle = @"Test Email Msg";
		category = CATEGORY_TASKS;
		summaryTitle = @"Test Tasks";

		NSDate *plus2Day = [NSDate dateWithTimeIntervalSinceNow:(2 * 24*60*60) -1];
		NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"Get Some Milk!",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   plus2Day,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self description], @"module",
							   @"list_id",@"list_id",
							   @"Go For a Walk",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   [NSDate distantFuture],@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDate *past = [NSDate dateWithTimeIntervalSinceNow:-60*60];
		NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"update the blog",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   past ,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDate *plusOneDay = [NSDate dateWithTimeIntervalSinceNow:(24*60*60) -1];
		NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"Complete the WENUS report",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   plusOneDay,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];	
		NSDate *plus3Day = [NSDate dateWithTimeIntervalSinceNow:(3*24*60*60) - 1];
		
		NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"Signup for Little League",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   plus3Day,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];	
		NSDate *plus5Day = [NSDate dateWithTimeIntervalSinceNow:(5*24*60*60) - 1];
		NSDictionary *dict6 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"get pvr to record Glee",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   plus5Day,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDate *reallysoon = [NSDate dateWithTimeIntervalSinceNow:30*60];

		NSDictionary *dict7 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"WorkPlayAway Screencast",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   reallysoon,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDate *sortasoon = [NSDate dateWithTimeIntervalSinceNow:3 * 60 *60];
	
		NSDictionary *dict8 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"WorkPlayAway bug fixing",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   sortasoon,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDate *sooner = [NSDate dateWithTimeIntervalSinceNow:1.5 * 60 *60];
		
		NSDictionary *dict9 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self name], @"module",
							   @"list_id",@"list_id",
							   @"Seriously, get a snack.",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   sooner,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];	
		allTasks = [NSMutableArray arrayWithObjects:
													dict1, dict2, dict3, dict4, dict5, dict6, dict7, dict8, dict9, nil];
	}
	return self;
}

- (void)awakeFromNib
{
	
}

-(void) refreshData: (id<AlertHandler>) handler
{
	NSMutableArray *incomp = [NSMutableArray new];
	for (NSDictionary *item in allTasks){
		BOOL done = ((NSNumber*)[item objectForKey:@"done"]).intValue;
		if (!done) {
			[incomp addObject:item];
		}
	}
	for (int i = 0; i < [incomp count];i++){
		NSDictionary *item = [incomp objectAtIndex:i];
	
			Note *alert = [[Note alloc]init];
			alert.moduleName = name;
			alert.title =[item objectForKey:@"name"];
			alert.message=[item objectForKey:@"name"];
			alert.clickable = YES;
			alert.params = item;
			[handler handleAlert:alert];
		
		
	}
	[BaseInstance sendDone:handler module: name];
}

-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary
{
	[self refreshData:handler];
}

- (void) handleClick:(NSDictionary *)ctx
{
	NSString *href = [ctx objectForKey:@"href"];
	NSURL *url = [NSURL URLWithString:href];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) markComplete:(NSDictionary *)ctx completeHandler:(NSObject*) callback
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:ctx];
	int idx = [allTasks indexOfObject:ctx];
	[newDict setObject:[NSNumber numberWithInt:1] forKey:@"done"];
	[allTasks replaceObjectAtIndex:idx withObject: newDict];
	[callback performSelector:@selector(handleComplete:) withObject:nil];
}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	refreshInterval = frequencyField.intValue * 60;
	[validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];
}

-(void) saveDefaults{ 
	[super saveDefaults];
	[super saveDefaultValue:[NSNumber numberWithInt:refreshInterval] forKey:REFRESH];
	[[NSUserDefaults standardUserDefaults] synchronize];
};



-(void) loadView
{
	[super loadView];
	[frequencyField setStringValue:[NSString stringWithFormat:@"%d", refreshInterval / 60]];

}

-(void) loadDefaults
{
	[super loadDefaults];
	NSNumber *temp =  [super loadDefaultForKey:REFRESH];
	if (temp) {
		refreshInterval = [temp intValue];
	}
}

-(void) clearDefaults{
	[super clearDefaults];

	[super clearDefaultValue:[NSNumber numberWithInt:frequencyField.intValue] forKey:REFRESH];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(IBAction) clickStepper: (id) sender
{
	frequencyField.intValue = stepper.intValue;
}

-(NSArray*) getTasks
{
	NSMutableArray *ret = [[NSMutableArray alloc]initWithCapacity:[allTasks count]];
	for (NSDictionary *item in allTasks){
		[ret addObject: [item objectForKey:@"name"] ];
	}
	return ret;
}

-(void) refreshTasks
{

}

- (NSString*) projectForTask:(NSString *)task{
	return nil;
}
@end
