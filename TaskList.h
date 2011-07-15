//
//  TaskList.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Instance.h"

@protocol TaskList <Instance>

- (NSArray*) getTasks;
- (void) refreshTasks;
- (void) markComplete:(NSDictionary *)ctx completeHandler:(NSObject*) target selector: (SEL) handler;
- (void) newTask:(NSString *)name completeHandler:(NSObject*) target selector: (SEL) handler;
- (BOOL) tracked;
@property (nonatomic, retain) NSString *defaultProject;
@end
