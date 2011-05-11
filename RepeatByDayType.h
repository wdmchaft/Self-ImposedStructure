//
//  RepeatByDayType.h
//  WorkPlayAway
//
//  Created by Charles on 5/7/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum  _DayOfWeek {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
} ;

typedef enum _DayOfWeek DayOfWeekType;

@interface RepeatByDayType : NSObject {
@private
    int numerator;
    DayOfWeekType day;
}
@property (nonatomic) int numerator;
@property (nonatomic) DayOfWeekType day;
@end


