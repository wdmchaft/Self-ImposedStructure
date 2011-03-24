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
//

@interface TotalsManager : NSObject {
	NSTimer *dailyRolloverTimer; // when the "roll over" to a new day occurs -- defaults to midnight but could be later
	NSDate *timeStampDate;  // the date recorded at rollover. 
	int rolloverDay;
	int rolloverHour;
	NSTimeInterval awayToday;
	NSTimeInterval freeToday;
	NSTimeInterval workToday;
	NSTimeInterval awayWeek;
	NSTimeInterval freeWeek;
	NSTimeInterval workWeek;
	NSTimeInterval interval;
    SummaryRecord  *summary;
	BOOL recordChecked;
}

@property (nonatomic) int rolloverDay;
@property (nonatomic) int rolloverHour;
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
@property (nonatomic) BOOL recordChecked;

//- (void) dailyRollover: (NSTimer*) timer;
//- (NSTimer*) getTimerForRollHour: (int) rollHour;
- (void) addInterval:(WPAStateType) state;
- (void) saveCurrent;
- (void) initFromRecord;

@end
