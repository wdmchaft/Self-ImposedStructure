//
//  WorkTable.h
//  WorkPlayAway
//
//  Created by Charles on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatsTable.h"

@interface WorkTable  : StatsTable {
	NSArray *workData;
}
@property (nonatomic,retain) NSArray *workData;
- (id) initWithRows: (NSArray*) data;

@end
