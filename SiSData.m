//
//  SiSData.m
//  Self-Imposed Structure
//
//  Created by Charles on 7/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SiSData.h"


@implementation SiSData

+ (NSArray*) getAllActiveProjects
{
	NSObject *delObj = [[NSApplication sharedApplication] delegate];
	if (![delObj respondsToSelector:@selector(allActiveProjects)]){
		NSAssert(NO, "does not support getAllActiveProjects");
	}
	return [delObj allActiveProjects];
}
@end
