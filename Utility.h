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
+ (NSData *)dataByBase64DecodingString:(NSString *)decode;

+(NSString*) timeStrFor:(NSDate*) date;
+(NSString*) shortTimeStrFor:(NSDate*) date;
+(NSString*) MdStrFor:(NSDate*) date;
+(NSString*) dStrFor:(NSDate*) date;

+ (NSString*) encode: (NSString*) inStr;
+ (NSString*) decode: (NSString*) inStr;

@end
