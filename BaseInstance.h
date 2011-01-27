//
//  BaseInstance.h
//  WorkPlayAway
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Instance.h"
#define ENABLED @"Enabled"


@interface BaseInstance : NSViewController <Instance> {

	BOOL enabled;
	
	NSString *description;
	NSString *notificationName;
	NSString *notificationTitle;
	NSObject *validationHandler;
	NSWindowController *detailController;
	WPAModuleCategory category;
	NSTimeInterval refreshInterval;
}

@property (nonatomic) BOOL enabled;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *notificationName;
@property (nonatomic, retain) NSString *notificationTitle;
@property (nonatomic, retain) NSObject *validationHandler;
@property (nonatomic, retain) NSWindowController *detailController;
@property (nonatomic) WPAModuleCategory category;
@property (nonatomic) NSTimeInterval refreshInterval;


-(void) saveDefaults;
-(void) loadDefaults;
-(void) clearDefaults;
-(void) startValidation:(NSObject *)handler;
-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(id) loadDefaultForKey: (NSString*) key;
+ (void) sendErrorToHandler:(<AlertHandler>) handler error:(NSString*) err module:(NSString*) modName;
+ (void) sendDone: (<AlertHandler>) handler module: (NSString*) modName;
@end

