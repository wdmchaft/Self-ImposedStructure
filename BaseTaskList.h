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
@interface BaseTaskList : BaseReporter <TaskList> {
	BOOL tracked;
}
@property (nonatomic, assign) BOOL tracked;
@end
