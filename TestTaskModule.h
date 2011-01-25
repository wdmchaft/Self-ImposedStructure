//
//  GmailModule.h
//  Nudge
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseInstance.h"
#import "Reporter.h"
#import "TaskList.h"

#define MAX_FAIL 3
@interface TestTaskModule : BaseInstance <Reporter, TaskList> {

	NSTextField *frequencyField;

	NSTimeInterval refresh;

	NSTimer *refreshTimer;
	NSStepper *stepper;
	NSMutableArray *allTasks;
}

@property (nonatomic) NSTimeInterval refresh;
@property (nonatomic, retain) NSTimer *refreshTimer;
@property (nonatomic, retain) IBOutlet NSTextField *frequencyField;
@property (nonatomic, retain) IBOutlet NSStepper *stepper;
@property (nonatomic) BOOL summaryMode;
@property (nonatomic,retain) NSMutableArray *allTasks;

-(IBAction) clickStepper: (id) sender;
- (void) refreshData:(<AlertHandler>)timer;

- (void) markComplete:(NSDictionary *)ctx;
@end