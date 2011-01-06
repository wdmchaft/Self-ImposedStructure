//
//  Utility.h
//  Nudge
//
//  Created by Charles on 11/22/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Utility : NSObject {
//	void* bytes;
//	int length;
}
//@property (nonatomic) void* bytes;
//@property (nonatomic) int length;
+(NSString *)base64EncodedString:(char*) bytes withLength: (int) length;

@end
