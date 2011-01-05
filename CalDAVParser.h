//
//  CalDevParser.h
//  GCalModule
//
//  Created by Charles on 12/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CalDAVParser : NSWindowController {
	NSString *data;
}
@property (nonatomic, retain) NSString *data;
- (void) parse: (NSObject*) handler;
@end
