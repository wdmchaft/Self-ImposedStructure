//
//  HeatMap.h
//  WorkPlayAway
//
//  Created by Charles on 3/10/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#define COLORS @"heatMapColors"
#define MINVALS @"heatMapMinValues"

@interface HeatMap : NSObject <NSTableViewDataSource> {
	NSMutableArray *colors;
	NSMutableArray *windows;
}
@property (nonatomic, retain) NSMutableArray *colors;
@property (nonatomic, retain) NSMutableArray *windows;

- (void) save;
- (void) load;
- (NSColor*) colorForInterval: (NSTimeInterval) interval;

@end
