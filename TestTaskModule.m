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

@synthesize refresh;
@synthesize frequencyField;
@synthesize refreshTimer;
@synthesize stepper;
@synthesize summaryMode;
@synthesize allTasks;
@dynamic notificationName;
@dynamic notificationTitle;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		super.description =@"Test Tasks";
		super.notificationName = @"Mail Alert";
		super.notificationTitle = @"Test Email Msg";
		super.category = CATEGORY_TASKS;

		NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self description], @"module",
							   @"list_id",@"list_id",
							   @"Milk!",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   [NSDate date],@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self description], @"module",
							   @"list_id",@"list_id",
							   @"remember the catfood",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDate *past = [NSDate dateWithTimeIntervalSinceNow:-60*60];
		NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self description], @"module",
							   @"list_id",@"list_id",
							   @"remember the dog",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   past ,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		NSDate *plusOneDay = [NSDate dateWithTimeIntervalSinceNow:24*60*60*60];
		NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self description], @"module",
							   @"list_id",@"list_id",
							   @"remember the french fries",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   plusOneDay,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];	
		NSDate *plus3Day = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60*60];
		
		NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self description], @"module",
							   @"list_id",@"list_id",
							   @"remember the dental floss",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   plus3Day,@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];	
		NSDictionary *dict6 = [NSDictionary dictionaryWithObjectsAndKeys:
							   [self description], @"module",
							   @"list_id",@"list_id",
							   @"don't forget",@"name",
							   @"taskseries_id",@"taskseries_id",
							   @"id",@"id",
							   [NSDate date],@"due_time",
							   [NSNumber numberWithInt:NO], @"done",
							   nil];
		allTasks = [NSMutableArray arrayWithObjects: dict1,dict2,dict3,dict4,dict5,dict6, nil];
	}
	return self;
}

- (void)awakeFromNib
{
	
}

-(void) refreshData: (<AlertHandler>) handler
{
	
	for (NSDictionary *item in allTasks){
		
		BOOL done = ((NSNumber*)[item objectForKey:@"done"]).intValue;
		if (!done) {
			Note *alert = [[Note alloc]init];
			alert.moduleName = super.description;
			alert.title =[item objectForKey:@"name"];
			alert.message=[item objectForKey:@"name"];
			if (summaryMode){
				alert.params = item;
			} else {			
				alert.params = item;
			}
			[handler handleAlert:alert];
		}
		
	}
	[BaseInstance sendDone:handler];
}

- (void) getSummary
{
	summaryMode = YES;
	[self refreshData: nil];
}

-(void) refresh: (<AlertHandler>) handler
{
	[self refreshData:handler];
}

- (void) handleClick:(NSDictionary *)ctx
{
	NSString *href = [ctx objectForKey:@"href"];
	NSURL *url = [NSURL URLWithString:href];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) markComplete: (NSDictionary *) ctx
{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:ctx];
	int idx = [allTasks indexOfObject:ctx];
	[newDict setObject:[NSNumber numberWithInt:1] forKey:@"done"];
	[allTasks replaceObjectAtIndex:idx withObject: newDict];
}

- (void) scheduleNextRefresh
{
	NSTimeInterval timeRef = refresh * 60;
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:timeRef
										   target:self 
										 selector: @selector(refreshData:) 
										 userInfo:nil
										  repeats:NO];

}

- (void) startValidation: (NSObject*) callback
{
	[super startValidation:callback];
	[super.validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];
}

-(void) saveDefaults{ 
	[super saveDefaults];
	[super saveDefaultValue:[NSNumber numberWithInt:refresh] forKey:REFRESH];
	[[NSUserDefaults standardUserDefaults] synchronize];
};



-(void) loadView
{
	[super loadView];
	[frequencyField setStringValue:[NSString stringWithFormat:@"%d", refresh]];

}

-(void) loadDefaults
{
	[super loadDefaults];
	NSNumber *temp =  [super loadDefaultForKey:REFRESH];
	if (temp) {
		refresh = [temp intValue];
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
