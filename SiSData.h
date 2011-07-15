//
//  SiSData.h
//  Self-Imposed Structure
//
//  Created by Charles on 7/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol SiSMetadata

+ (NSArray*) getAllActiveProjects;

@end

@interface SiSData : NSObject <SiSMetadata>
{

}
+ (NSArray*) getAllActiveProjects;

@end

