//
//  TaskInfo.h
//  WorkPlayAway
//
//  Created by Charles on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Instance.h"
#import "TaskList.h"

@interface TaskInfo : NSObject {
	id<TaskList> source;
	NSString *name;
	NSString *project;
	NSString *description;
}

@property (nonatomic, retain) id<TaskList> source;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *project;
@property (nonatomic,retain) NSString *description;

-(id) initWithName: (NSString*) item source: (id<TaskList>) mod  project: (NSString*) proj;
@end
