//
//  CalDevParser.h
//  GCalModule
//
//  Created by Charles on 12/6/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MimeHandler : NSObject {
}
+ (NSString*) synopsis: (NSString*) data;
+ (NSString*)synopsisFromMultiPart: (NSString*) data;
+ (NSString*)synopsisFromSimple: (NSString*) data;
+ (NSArray*) getBoundaries: (NSString*) data;
+ (NSInteger) findEnd: (NSString*) data withBoundaries: (NSArray*) boundaries;
+ (BOOL) isQuotedBoundary: (NSString*) srchStr;
+ (NSUInteger) getBoundaryFrom:(NSString*) srchStr ret:(NSString**) retString;

@end
