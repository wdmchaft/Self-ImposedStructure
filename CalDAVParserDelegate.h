//
//  CalDAVParserDelegate.h
//  GCalModule
//
//  Created by Charles on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol CalDAVParserDelegate  <NSObject>

-(void) beginEvent;
-(void) endEvent;
-(void) dateStart: (NSString*) str;
-(void) dateEnd: (NSString*) str;
-(void) summary: (NSString*) str;
-(void) eventDescription: (NSString*) str;
-(void) location: (NSString*) str;

@end
