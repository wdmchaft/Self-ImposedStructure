//
//  GmailModule.m
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "TestEventModule.h"
#import "Note.h"


#define REFRESH @"Refresh"


@implementation TestEventModule

@synthesize refresh;

@synthesize frequencyField;
@synthesize stepper;
@dynamic notificationName;
@dynamic notificationTitle;


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		super.description =@"Test Event Module";
		super.notificationName = @"Mail Alert";
		super.notificationTitle = @"Test Email Msg";
		super.category = CATEGORY_EVENTS;
		refresh = 600;
	}
	return self;
}

- (void)awakeFromNib
{

}


-(void) refreshData: (<AlertHandler>) handler
{
	NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"in the drawing room", @"location",
						   [super description],@"module",
						   @"kill professor plum with pipewrench",@"desc",
						   @"kill professor plum",@"summary",
						   [NSDate date],@"starts",
						   [NSDate dateWithTimeIntervalSinceNow:60*60],@"ends",
						   nil];
	NSDictionary *dict2= [NSDictionary dictionaryWithObjectsAndKeys:
						   @"in the conservatory", @"location",
						   [super description],@"module",
						   @"kill mrs jones with revolver",@"desc",
						   @"kill mrs jones",@"summary",
						   [NSDate dateWithTimeIntervalSinceNow:-60*60],@"starts",
						   [NSDate dateWithTimeIntervalSinceNow:60*60],@"ends",
						   nil];
	
	NSDictionary *dict3= [NSDictionary dictionaryWithObjectsAndKeys:
						  @"in the ballroom", @"location",
						  [super description],@"module",
						  @"do a little dance",@"desc",
						  @"do a little dance, make a little love, get down tonight!",@"summary",
						  [NSDate dateWithTimeIntervalSinceNow:24*60*60],@"starts",
						  [NSDate dateWithTimeIntervalSinceNow:26*60*60],@"ends",
						  nil];
	

	NSArray *msgs = [NSArray arrayWithObjects: dict1,dict2,dict3, nil];
	for (NSDictionary *item in msgs){
		
		Note *alert = [[Note alloc]init];
		alert.moduleName = super.description;
		alert.title =[item objectForKey:@"desc"];
		alert.message=[item objectForKey:@"summary"];
		alert.params = item;
		
		[handler handleAlert:alert];
		
	}
	[BaseInstance sendDone:handler];

	
}

- (void) refresh: (<AlertHandler>) handler;
{
	[self refreshData: handler];
}


- (void) handleClick:(NSDictionary *)ctx
{
	NSString *href = [ctx objectForKey:@"href"];
	NSURL *url = [NSURL URLWithString:href];
	[[NSWorkspace sharedWorkspace] openURL:url];
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

@end
