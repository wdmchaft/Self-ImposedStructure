//
//  GoalManager.h
//  WorkPlayAway
//
//  Created by Charles on 1/28/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "SummaryRecord.h"
#import "RolloverDelegate.h"
//

@interface TotalsManager : NSObject {
	NSTimer *dailyRolloverTimer; // when the "roll over" to a new day occurs -- defaults to midnight but could be later
	NSDate *timeStampDate;  // the date recorded at rollover. 
	int rolloverDay;
	NSDate *rolloverTime;
	NSTimeInterval awayToday;
	NSTimeInterval freeToday;
	NSTimeInterval workToday;
	NSTimeInterval awayWeek;
	NSTimeInterval freeWeek;
	NSTimeInterval workWeek;
	NSTimeInterval interval;
    SummaryRecord  *summary;
	BOOL recordChecked;
	id<RolloverDelegate> rollDelegate;
}

@property (nonatomic) int rolloverDay;
@property (nonatomic,retain) NSDate* rolloverTime;
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) NSTimeInterval awayToday;
@property (nonatomic) NSTimeInterval freeToday;
@property (nonatomic) NSTimeInterval workToday;
@property (nonatomic) NSTimeInterval awayWeek;
@property (nonatomic) NSTimeInterval freeWeek;
@property (nonatomic) NSTimeInterval workWeek;
@property (nonatomic,retain) SummaryRecord *summary;
@property (nonatomic,retain) NSTimer *dailyRolloverTimer;
@property (nonatomic,retain) NSDate *timeStampDate;
@property (nonatomic,retain) id<RolloverDelegate> rollDelegate;
@property (nonatomic) BOOL recordChecked;

//- (void) dailyRollover: (NSTimer*) timer;
//- (NSTimer*) getTimerForRollHour: (int) rollHour;
- (void) addInterval:(WPAStateType) state;
- (void) saveCurrent;
- (void) initFromRecord;
- (double) calcGoal;
- (BOOL) isVacationToday;

@end
