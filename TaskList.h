//
//  TaskList.h
//  WorkPlayAway
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol TaskList

- (NSArray*) getTasks;
- (void) refreshTasks;
- (NSString*) projectForTask: (NSString*) task;
- (void) markComplete:(NSDictionary *)ctx;
@end