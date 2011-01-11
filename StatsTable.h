//
//  StatsTable.h
//  WorkPlayAway
//
//  Created by Charles on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define ACTIVITY_COL @"Activity"
#define TASK_COL @"Task"
#define SOURCE_COL @"Source"
#define TODAY_COL @"Today"
#define CUR_WEEK_COL @"Last 7 Days"
#define CUR_MONTH_COL @"Last 30 Days"
#define CUR_HOUR_COL @"Last Hour"

@interface StatsTable : NSObject <NSTableViewDataSource> {
}

-(NSString*) formatTimePeriod: (NSTimeInterval) interval;
@end
