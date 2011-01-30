//
//  GoalManager.h
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
//

@interface TotalsManager : NSObject {
	NSTimer *dailyRolloverTimer;
	int rolloverDay;
	NSTimeInterval awayToday;
	NSTimeInterval freeToday;
	NSTimeInterval workToday;
	NSTimeInterval awayWeek;
	NSTimeInterval freeWeek;
	NSTimeInterval workWeek;
	NSTimeInterval interval;
}

@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) NSTimeInterval awayToday;
@property (nonatomic) NSTimeInterval freeToday;
@property (nonatomic) NSTimeInterval workToday;
@property (nonatomic) NSTimeInterval awayWeek;
@property (nonatomic) NSTimeInterval freeWeek;
@property (nonatomic) NSTimeInterval workWeek;
@property (nonatomic) int rolloverDay;
@property (nonatomic,retain) NSTimer *dailyRolloverTimer;

//- (void) dailyRollover: (NSTimer*) timer;
//- (NSTimer*) getTimerForRollHour: (int) rollHour;
- (void) addInterval:(WPAStateType) state;
@end