//
//  GmailModule.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/23/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"
#import "Reporter.h"

#define MAX_FAIL 3
@interface TestEventModule : BaseReporter <Reporter> {

	NSTextField *frequencyField;
	NSStepper *stepper;
//	NSTimeInterval refreshInterval;
}

@property (nonatomic, retain) IBOutlet NSTextField *frequencyField;
@property (nonatomic, retain) IBOutlet NSStepper *stepper;
//@property (nonatomic) NSTimeInterval refreshInterval;

-(IBAction) clickStepper: (id) sender;

@end
