//
//  AppleMailDaemon.h
//  WorkPlayAway
//
//  Created by Charles on 5/9/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppleScriptEventHandler.h"

@interface MailEventHandler : NSObject <AppleScriptEventHandler> {
	NSDateFormatter *mailDateFmt;
}

@property (nonatomic, retain) NSDateFormatter *mailDateFmt;


@end
