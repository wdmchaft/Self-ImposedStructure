//
//  Schema.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/6/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatsRecord.h"
#import "State.h"
@interface Schema : NSObject {

}
+ (NSString*) dumpMObj: (NSManagedObject*) obj;
+ (BOOL) hasTask: (NSManagedObject*) mobj;
+ (NSString*) entityNameForState:(WPAStateType) state;
+ (NSManagedObject*) findTask: (NSString*) name inContext: (NSManagedObjectContext*) moc;
+ (double) countEntity: (NSString*) name inContext: (NSManagedObjectContext*) moc;
+ (void) fetchIntoRecord: (StatsRecord*) record 
			  fromArray: (NSArray*) array
			  usingWeek: (NSDate*) weekDate 
			   usingDay: (NSDate*) dayDate
			   usingHour: (NSDate*) hourDate;

+ (NSArray*) statsReportForDate :(NSDate*) date inContext: (NSManagedObjectContext*)moc;
+ (NSArray*) fetchWorkReportForMonth: (NSDate*) date
						   inContext: (NSManagedObjectContext*)moc;
@end
