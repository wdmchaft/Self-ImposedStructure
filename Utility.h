//
//  Utility.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/22/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Utility : NSObject {
//	void* bytes;
//	int length;
}
//@property (nonatomic) void* bytes;
//@property (nonatomic) int length;
+ (NSString *)base64EncodedString:(char*) bytes withLength: (int) length;
+ (NSData *)dataByBase64DecodingString:(NSString *)decode;

+ (NSString*) timeStrFor:(NSDate*) date;
+ (NSString*) shortTimeStrFor:(NSDate*) date;
+ (NSString*) dueTimeStrFor:(NSDate*) date;
+ (NSString*) MdStrFor:(NSDate*) date;
+ (NSString*) dStrFor:(NSDate*) date;

+ (NSString*) encode: (NSString*) inStr;
+ (NSString*) decode: (NSString*) inStr;
+ (void) saveColors: (NSArray*) colors forKey: (NSString*)key;
+ (NSData*) archColorWithRed: (double) rd green: (double) gr blue: (double) bl;
+ (NSData*) archColorWithHue : (double) hue 
                  saturation : (double) saturation 
                  brightness : (double) brightness;
+ (NSColor*) colorFromArch: (NSData*) data;

+ (NSArray*) loadColorsForKey: (NSString*) key;
+ (NSString*) formatInterval: (NSTimeInterval) timeInt;
+ (NSString*) applicationSupportDirectory;

@end
