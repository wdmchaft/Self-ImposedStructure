//
//  SummaryTable.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/10/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatsTable.h"

@interface SummaryTable : StatsTable {
	NSArray *statData;
}
@property (nonatomic,retain) NSArray *statData;

- (id) initWithRows: (NSArray*) data;

@end
