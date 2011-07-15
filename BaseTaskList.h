//
//  BaseTaskList.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseReporter.h"
#import "TaskList.h"

#define TRACKED @"Tracked"
#define DEFAULTPROJECT @"DefaultProject"
@interface BaseTaskList : BaseReporter <TaskList> {
	BOOL tracked;
	NSString *defaultProject;
}
@property (nonatomic, assign) BOOL tracked;
@property (nonatomic, retain) NSString *defaultProject;

- (NSString *) completeQueue;
@end
