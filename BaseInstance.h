//
//  BaseInstance.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Instance.h"
#define ENABLED @"Enabled"


@interface BaseInstance : NSViewController <Instance> {

	BOOL enabled;
	
	NSString *name;
	NSString *notificationName;
	NSString *notificationTitle;
	NSObject *validationHandler;
	NSWindowController *detailController;
	WPAModuleCategory category;
	NSTimeInterval refreshInterval;
}

@property (nonatomic) BOOL enabled;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *notificationName;
@property (nonatomic, retain) NSString *notificationTitle;
@property (nonatomic, retain) NSObject *validationHandler;
@property (nonatomic, retain) NSWindowController *detailController;
@property (nonatomic) WPAModuleCategory category;
@property (nonatomic) NSTimeInterval refreshInterval;


- (void) saveDefaults;
- (void) loadDefaults;
- (void) clearDefaults;
- (void) startValidation:(NSObject *)handler;
- (void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key;
- (void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key;
- (id) loadDefaultForKey: (NSString*) key;
- (BOOL) loadBoolDefaultForKey: (NSString*) key;
- (double) loadDoubleDefaultForKey: (NSString*) key;

+ (void) sendErrorToHandler:(id<AlertHandler>) handler error:(NSString*) err module:(NSString*) modName;
+ (void) sendDone: (id<AlertHandler>) handler module: (NSString*) modName;
- (NSString*) myKeyForKey: (NSString*) key;

@end

