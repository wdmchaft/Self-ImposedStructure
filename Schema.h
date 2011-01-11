//
//  Schema.h
//  WorkPlayAway
//
//  Created by Charles on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatsRecord.h"

@interface Schema : NSObject {

}
+ (NSString*) dumpMObj: (NSManagedObject*) obj;
+ (BOOL) hasTask: (NSManagedObject*) mobj;
+ (NSString*) entityNameForState:(int) state;
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
