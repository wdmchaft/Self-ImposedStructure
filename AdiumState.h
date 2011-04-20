//
//  ADIUMState.h
//  ADIUMMonitor
//
//  Created by Charles on 12/19/10.
//  Copyright 2010 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Adium.h"

typedef enum {
	ADIUM_STATE_AWAY = AdiumStatusTypesAway,  
	ADIUM_STATE_INVISIBLE = AdiumStatusTypesInvisible, 
	ADIUM_STATE_ONLINE = AdiumStatusTypesAvailable, ADIUM_STATE_INVALID 
} AdiumStateType;


@interface AdiumState : NSObject {
}
+ (NSString*) stateToString: (AdiumStateType) state;

@end
