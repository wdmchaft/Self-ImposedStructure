//
//  StatsRecord.h
//  WorkPlayAway
//
//  Created by Charles on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatsRecord : NSObject {
	NSString *activity;
	NSString *task;
	NSString *source;
	NSTimeInterval hour;
	NSTimeInterval today;
	NSTimeInterval week;
	NSTimeInterval month;
}
@property (nonatomic, retain) NSString *activity;
@property (nonatomic, retain) NSString *task;
@property (nonatomic, retain) NSString *source;
@property (nonatomic) NSTimeInterval hour;
@property (nonatomic) NSTimeInterval today;
@property (nonatomic) NSTimeInterval week;
@property (nonatomic) NSTimeInterval month;
- (id) initWithName: (NSString*) name;
@end
