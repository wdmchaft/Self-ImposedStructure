//
//  IconsFile.h
//  Nudge
//
//  Created by Charles on 12/16/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IconsFile : NSObject {
	NSDictionary *iconLookup;
	NSData *data;
}
@property (nonatomic, readonly) NSDictionary *iconLookup;
@property (nonatomic, readonly) NSData *data;

- (void) loadIconData: (NSData*) data;
- (int) bytesToInt: (char*) chars;
- (NSData*) getIconForHeight: (int) height;
@end
