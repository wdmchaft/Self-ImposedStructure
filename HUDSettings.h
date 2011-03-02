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
	<Reporter> reporter;
	NSString *label;
	BOOL enabled;
	NSUInteger height;
}
@property (nonatomic, retain)	<Reporter>	reporter;
@property (nonatomic, retain)	NSString	*label;
@property (nonatomic)			BOOL		enabled;
@property (nonatomic)			NSUInteger	height;
@end

@interface HUDSettings : NSObject <NSTableViewDataSource> {
	NSMutableArray *heights;
	NSMutableArray *enables;
	NSMutableArray *labels;
	NSMutableArray *instances;
}
@property (nonatomic, retain) NSMutableArray *heights;
@property (nonatomic, retain) NSMutableArray *enables;
@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, retain) NSMutableArray *instances;


- (void) addInstance: (<Reporter>) inst ;

-( void) addInstance: (<Reporter>) inst 
			 height: (int) hgt
			  label: (NSString*) lbl
			enabled: (BOOL) on;

- (void) addInstance: (<Reporter>) inst 
			 height: (int) hgt
			  label: (NSString*) lbl
			enabled: (BOOL) on
			  index: (int) idx;

- (void) removeInstance: (<Reporter>) inst;

- (void) clear;

- (void) readFromDefaults;

- (void) saveToDefaults;

- (HUDSetting*) settingAtIndex: (int) idx;

- (NSUInteger) count;

- (NSArray*) allEnabled;

- (void) disableInstance: (<Reporter>) inst;
@end
