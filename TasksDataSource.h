//
//  TasksDataSource.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/26/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDRec : NSObject
{
	NSString *task;
	NSString *project;
	NSDate *complete;
	NSNumber *duration;
}

@property (nonatomic, retain) NSString *task;
@property (nonatomic, retain) NSString *project;
@property (nonatomic, retain) NSDate *complete;
@property (nonatomic, retain) NSNumber *duration;

@end

@interface TasksDataSource : NSObject <NSTableViewDataSource> {
@private 
	NSMutableArray *data;
	NSDateFormatter *format;
}

@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) NSDateFormatter *format;

- (void) runQueryStarting: (NSDate*) start ending: (NSDate*) end withContext: (NSManagedObjectContext *) moc;

@end
