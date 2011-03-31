//
//  HUDSettings.h
//  WorkPlayAway
//
//  Created by Charles on 3/1/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
@interface HUDSetting : NSObject {
	id<Reporter> reporter;
	NSString *label;
	BOOL enabled;
	NSUInteger height;
}
@property (nonatomic, retain)	id<Reporter>	reporter;
@property (nonatomic, retain)	NSString	*label;
@property (nonatomic)			BOOL		enabled;
@property (nonatomic)			NSUInteger	height;
@end

@interface HUDSettings : NSObject <NSTableViewDataSource> {
	NSMutableArray *lines;
	NSMutableArray *enables;
	NSMutableArray *labels;
	NSMutableArray *instances;
}
@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) NSMutableArray *enables;
@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, retain) NSMutableArray *instances;


- (void) addInstance: (id<Reporter>) inst ;

-( void) addInstance: (id<Reporter>) inst 
			 height: (int) hgt
			  label: (NSString*) lbl
			enabled: (BOOL) on;

- (void) addInstance: (id<Reporter>) inst 
			 height: (int) hgt
			  label: (NSString*) lbl
			enabled: (BOOL) on
			  index: (int) idx;

- (void) removeInstance: (id<Reporter>) inst;

- (void) clear;

- (void) readFromDefaults;

- (void) saveToDefaults;

- (HUDSetting*) settingAtIndex: (int) idx;

- (NSUInteger) count;

- (NSArray*) allEnabled;

- (void) disableInstance: (id<Reporter>) inst;
- (NSString*) labelForInstance: (id<Instance>) inst;
@end
