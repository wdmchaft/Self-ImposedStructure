//
//  Instance.h
//  WorkPlayAway
//
//  Created by Charles on 1/22/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "State.h"
#import "AlertHandler.h"

typedef enum {
	CATEGORY_OTHER, CATEGORY_EVENTS, CATEGORY_EMAIL, CATEGORY_CHAT_CONTROL, CATEGORY_TASKS
} WPAModuleCategory;
@protocol Instance <NSObject, NSCopying, NSCoding>
/** basic required */
@required
- (void) startValidation:(NSObject*) handler;
- (void) clearValidation;
- (void) saveDefaults;
- (void) loadDefaults;
- (void) clearDefaults;
@property (nonatomic) WPAModuleCategory category;
@property (nonatomic, retain) NSString* name;
@property (nonatomic) BOOL enabled ;// allows the module to be turned on and off

/* All that follow are optional

 any module can implement 
- (void) stateChange:(WPAStateType)  newState;

** optional but must all be implemented for reporting modules:
- (void) refresh: (<AlertHandler>) handler;
- (void) handleClick: (NSDictionary*) params;
@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, retain) NSString* notificationTitle;

** The following are optional but must all be implemented for task list modules 
- (NSArray*) getTasks;
- (void) refreshTasks;
- (NSString*) projectForTask: (NSString*) task;
*/
@end
