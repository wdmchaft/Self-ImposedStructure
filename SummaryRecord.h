//
//  SummaryRecord.h
//  WorkPlayAway
//
//  Created by Charles on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface SummaryRecord : NSObject {
@private
    NSDate *dateStart;
    NSNumber *timeTotal;
    NSNumber *timeWorked;
    NSNumber *daysTotal;
    NSNumber *daysWorked;
    NSNumber *timeGoal;
    NSNumber *daysGoalAchieved;
    NSDate *dateWrite;
    NSDate *lastDay;
    NSDate *lastWorked;
    NSDate *lastGoalAchieved;
}
@property (nonatomic, retain) NSDate *dateStart;
@property (nonatomic, retain) NSNumber *timeTotal;
@property (nonatomic, retain) NSNumber *timeWorked;
@property (nonatomic, retain) NSNumber *daysTotal;
@property (nonatomic, retain) NSNumber *daysWorked;
@property (nonatomic, retain) NSNumber *timeGoal;
@property (nonatomic, retain) NSNumber *daysGoalAchieved;
@property (nonatomic, retain) NSDate *dateWrite;
@property (nonatomic, retain) NSDate *lastDay;
@property (nonatomic, retain) NSDate *lastWorked;
@property (nonatomic, retain) NSDate *lastGoalAchieved;

- (id) initWithEntity: (NSManagedObject*) summary;

@end
