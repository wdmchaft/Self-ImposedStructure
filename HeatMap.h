//
//  HeatMap.h
//  WorkPlayAway
//
//  Created by Charles on 3/10/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#define COLORS @"heatMapColors"
#define WINDOWS @"heatMapWindows"

@interface HeatMap : NSObject {
	NSArray *colors;
	NSArray *windows;
}
@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSArray *windows;

- (void) save;
- (void) load;
- (NSColor*) colorForInterval: (NSTimeInterval) interval;

@end
