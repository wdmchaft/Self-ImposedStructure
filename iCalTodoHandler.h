//
//  iCalTodoHandler.h
//  WorkPlayAway
//
//  Created by Charles on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppleScriptEventHandler.h"

@interface iCalTodoHandler : NSObject <AppleScriptEventHandler> {
@private
	NSDateFormatter *iCalDateFmt;
}
@property (nonatomic,retain) NSDateFormatter *iCalDateFmt;

@end
