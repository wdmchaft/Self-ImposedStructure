//
//  SummaryData.h
//  WorkPlayAway
//
//  Created by Charles on 1/19/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SummaryData : NSObject <NSTableViewDataSource> {
	NSMutableArray *data;
}
@property (nonatomic, retain) NSMutableArray *data;

- (void) sort;
@end
