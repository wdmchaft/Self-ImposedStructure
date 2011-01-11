//
//  BaseModule.h
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Module.h"


@interface BaseModule : NSViewController <Module> {
@protected
	BOOL thinking;
	BOOL away;
	BOOL started;
	BOOL sticky;
	BOOL enabled;
	NSString *lastError;
	NSString *description;
	NSString *notificationName;
	NSString *notificationTitle;
	NSString *displayName;
	NSObject *validationHandler;
	<AlertHandler> handler;
	NSWindowController *detailController;
	NSArray *trackingItems;
}

@property (nonatomic) BOOL sticky;
@property (nonatomic) BOOL thinking;
@property (nonatomic) BOOL started;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL away;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *notificationName;
@property (nonatomic, retain) NSString *notificationTitle;
@property (nonatomic, retain) <AlertHandler> handler;
@property (nonatomic, retain) NSObject *validationHandler;
@property (nonatomic, retain) NSString *lastError;
@property (nonatomic, retain) NSWindowController *detailController;
@property (nonatomic, readonly) NSArray *trackingItems;

-(void) sendError: (NSString*) error module: (NSString*) modName;
-(void) saveDefaults;
-(void) loadDefaults;
-(void) clearDefaults;
-(void) startValidation:(NSObject *)handler;
-(void) saveDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(void) clearDefaultValue: (NSObject*) val forKey: (NSString*) key;
-(id) loadDefaultForKey: (NSString*) key;
//-(void) createTrackingItem: (NSString*) item;
- (void) refreshTasks;

- (NSWindowController*) getDetailWindow: (NSDictionary*) params;
+ (NSString*) decode: (NSString*) inStr;
+ (NSString*) encode: (NSString*) inStr;
@end
