//
//  TaskInfo.h
//  WorkPlayAway
//
//  Created by Charles on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Module.h"

@interface TaskInfo : NSObject {
	<Module> source;
	NSString *name;
	NSString *project;
}

@property (nonatomic, retain) <Module> source;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *project;

-(id) initWithName: (NSString*) item source: (<Module>) mod  project: (NSString*) proj;
@end
