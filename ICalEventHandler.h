//
//  ICalEventHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/9/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppleScriptEventHandler.h"


@interface ICalEventHandler : NSObject <AppleScriptEventHandler>  {
	NSDateFormatter *iCalDateFmt;
}
@property (nonatomic,retain) NSDateFormatter *iCalDateFmt;
@end
