//
//  AppleMailDaemon.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/9/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppleScriptEventHandler.h"

@interface MailEventHandler : NSObject <AppleScriptEventHandler> {
	NSDateFormatter *mailDateFmt;
}

@property (nonatomic, retain) NSDateFormatter *mailDateFmt;


@end
