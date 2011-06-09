//
//  GmailModule.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "TestEventModule.h"
#import "WPAAlert.h"


#define REFRESH @"Refresh"


@implementation TestEventModule

@synthesize frequencyField;
@synthesize stepper;
@dynamic refreshInterval;
@dynamic notificationName;
@dynamic notificationTitle;
@dynamic name;
@dynamic enabled;
@dynamic category;
@dynamic summaryTitle;
@dynamic isWorkRelated;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		name =@"Test Event Module";
		notificationName = @"Mail Alert";
		notificationTitle = @"Test Email Msg";
		category = CATEGORY_EVENTS;
		refreshInterval = 600;
		[frequencyField setStringValue:[NSString stringWithFormat:@"%d", refreshInterval / 60 ]];
		summaryTitle = @"Test Event";
	}
	return self;
}

- (void)awakeFromNib
{
	[frequencyField setStringValue:[NSString stringWithFormat:@"%d", refreshInterval / 60 ]];

}


-(void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary useCache: (BOOL) cached
{
	NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"in the drawing room",	@"location",
						   [self name],		@"module",
						   @"Win at Bridge",		@"desc",
						   @"Bridge Club Meeting",	@"summary",
						   [NSDate date],			@"start",
						   [NSDate dateWithTimeIntervalSinceNow:60*60],@"start",
						   nil];
	NSDictionary *dict2= [NSDictionary dictionaryWithObjectsAndKeys:
						   @"Dentist Office",	@"location",
						   [self name],	@"module",
						   @"Teeth Cleaning",	@"desc",
						   @"get nice white teeth",	@"summary",
						   [NSDate dateWithTimeIntervalSinceNow:3 * 60*60],@"start",
						   [NSDate dateWithTimeIntervalSinceNow:4 * 60*60],@"end",
						   nil];
	
	NSDictionary *dict3= [NSDictionary dictionaryWithObjectsAndKeys:
						  @"in the ballroom",	@"location",
						  [self name],	@"module",
						  @"do a little dance",	@"desc",
						  @"Date Night",		@"summary",
						  [NSDate dateWithTimeIntervalSinceNow:24*60*60],@"start",
						  [NSDate dateWithTimeIntervalSinceNow:26*60*60],@"end",
						  nil];
	

	NSArray *msgs = [NSArray arrayWithObjects: dict1,dict2,dict3, nil];
	for (int i = 0; i < [msgs count];i++){
		NSDictionary *item = [msgs objectAtIndex:i];
		WPAAlert *alert = [[WPAAlert alloc]init];
		alert.moduleName = name;
		alert.title =[item objectForKey:@"desc"];
		alert.message=[item objectForKey:@"summary"];
		alert.params = item;
		[handler handleAlert:alert];
		
	}
	[BaseInstance sendDone: handler module: name];
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
	refreshInterval = frequencyField.intValue * 60;
	[validationHandler performSelector:@selector(validationComplete:) 
								  withObject:nil];
}

-(void) saveDefaults{ 
	[super saveDefaults];
	NSTimeInterval temp = refreshInterval;
	[super saveDefaultValue:[NSNumber numberWithInt:temp] forKey:REFRESH];
	[[NSUserDefaults standardUserDefaults] synchronize];
};


-(void) loadView
{
	[super loadView];
	[frequencyField setStringValue:[NSString stringWithFormat:@"%d", refreshInterval / 60 ]];
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
@end
