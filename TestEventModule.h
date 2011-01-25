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

#define MAX_FAIL 3
@interface TestEventModule : BaseInstance <Reporter> {

	NSTextField *frequencyField;

	NSTimeInterval refresh;

	NSStepper *stepper;
}

@property (nonatomic) NSTimeInterval refresh;
@property (nonatomic, retain) IBOutlet NSTextField *frequencyField;
@property (nonatomic, retain) IBOutlet NSStepper *stepper;

-(IBAction) clickStepper: (id) sender;
- (void) refreshData:(<AlertHandler>)timer;

@end
