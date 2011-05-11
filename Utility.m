//
//  Utility.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/22/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "Utility.h"
#include <openssl/bio.h>
#include <openssl/evp.h>

@implementation Utility
//@synthesize bytes;
//@synthesize length;
 
+ (NSString *)base64EncodedString:(char*) bytes withLength: (int) length
{
    // Construct an OpenSSL context
    BIO *context = BIO_new(BIO_s_mem());
	
    // Tell the context to encode base64
    BIO *command = BIO_new(BIO_f_base64());
    context = BIO_push(command, context);
	
    // Encode all the data
    BIO_write(context, bytes, length);
    BIO_flush(context);
	
    // Get the data out of the context
    char *outputBuffer;
    BIO_get_mem_data(context, &outputBuffer);
    NSString *encodedString = [NSString
							   stringWithCString:outputBuffer encoding: NSUTF8StringEncoding];
							//   length:outputLength];
	int len = [encodedString length];
	encodedString = [encodedString substringToIndex:len-1];
    BIO_free_all(context);
	
    return encodedString;
}

+ (NSData *)dataByBase64DecodingString:(NSString *)decode
{
    decode = [decode stringByAppendingString:@"\n"];
    NSData *data = [decode dataUsingEncoding:NSASCIIStringEncoding];
    
    // Construct an OpenSSL context
    BIO *command = BIO_new(BIO_f_base64());
    BIO *context = BIO_new_mem_buf((void *)[data bytes], [data length]);
	
    // Tell the context to encode base64
    context = BIO_push(command, context);
	
    // Encode all the data
    NSMutableData *outputData = [NSMutableData data];
    
#define BUFFSIZE 256
    int len;
    char inbuf[BUFFSIZE];
    while ((len = BIO_read(context, inbuf, BUFFSIZE)) > 0)
    {
        [outputData appendBytes:inbuf length:len];
    }
	
    BIO_free_all(context);
    [data self]; // extend GC lifetime of data to here
	
    return outputData;
}

+(NSString*) timeStrFor:(NSDate*) date
{
	NSString *ret = nil;
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"yyyyMMdd" ];
	NSString *todayStr = [compDate stringFromDate:[NSDate date]];
	NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:24*60*60];
	NSString *tomorrowStr = [compDate stringFromDate:tomorrow];
	NSString *eDateStr = [compDate stringFromDate:date];
	if ([todayStr isEqualToString:eDateStr]){
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"hh:mm"];
		ret = [NSString stringWithFormat:@"Today at %@", [timeDate stringFromDate:date]];
	}
	else if ([tomorrowStr isEqualToString:eDateStr] ){
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"hh:mm"];
		ret = [NSString stringWithFormat:@"Tomorrow at %@", [timeDate stringFromDate:date]];
		
	}else{
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"M/dd'-'hh:mm"];
		ret = [timeDate stringFromDate:date];
	}
	return ret;
}
+(NSString*) shortTimeStrFor:(NSDate*) date
{
	if (date == nil){
		//NSLog(@"nil date!");
		return @"";
	}
	NSString *ret = nil;
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"yyyyMMdd" ];
	NSString *todayStr = [compDate stringFromDate:[NSDate date]];
	NSString *eDateStr = [compDate stringFromDate:date];
	if ([todayStr isEqualToString:eDateStr]){
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"hh:mm"];
		ret = [NSString stringWithFormat:@"%@", [timeDate stringFromDate:date]];
	}
	else{
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"M/dd'-'hh:mm"];
		ret = [timeDate stringFromDate:date];
	}
	return ret;
}

+(NSString*) dueTimeStrFor:(NSDate*) date
{
	if (date == nil){
		//NSLog(@"nil date!");
		return @"";
	}
	NSString *ret = nil;
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"yyyyMMdd" ];
	NSString *todayStr = [compDate stringFromDate:[NSDate date]];
	NSString *eDateStr = [compDate stringFromDate:date];
	if ([todayStr isEqualToString:eDateStr]){
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"hh:mm"];
		return [NSString stringWithFormat:@"%@", [timeDate stringFromDate:date]];
	}
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSUInteger calFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	// events that fall exactly @ midnight are just "day" events - today, tommorow... the future date
	NSDateComponents *comps = [cal components:calFlags fromDate:date];
	if (comps.hour == 0 && comps.minute == 0 && comps.second == 0) {
		NSTimeInterval fromNow = [date timeIntervalSinceNow];
		if (fromNow < 24 * 60 * 60) {
			return @"Today";
		} else if (fromNow < 48 * 60 * 60) {
			return @"Tomorrow";
		} else {
			NSDateFormatter *timeDate = [NSDateFormatter new];
			[timeDate setDateFormat: @"eee"];
			return [timeDate stringFromDate:date];
		}
	}
	else {
		NSDateFormatter *timeDate = [NSDateFormatter new];
		[timeDate setDateFormat: @"eee'-'hh:mm"];
		ret = [timeDate stringFromDate:date];
	}
	return ret;
}

+(NSString*) MdStrFor:(NSDate*) date
{
	if (date == nil){
		//NSLog(@"nil date!");
		return @"";
	}
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"M/d" ];
	NSString *eDateStr = [compDate stringFromDate:date];
	return eDateStr;
}

+(NSString*) dStrFor:(NSDate*) date
{
	if (date == nil){
		//NSLog(@"nil date!");
		return @"";
	}
	NSDateFormatter *compDate = [NSDateFormatter new];;
	[compDate  setDateFormat:@"d" ];
	NSString *eDateStr = [compDate stringFromDate:date];
	return eDateStr;
}
+ (NSString*) encode: (NSString*) inStr
{
	NSString *out = [inStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	out = [out stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
	return out;
}

+ (NSString*) decode: (NSString*) inStr
{
	NSString *out = [inStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	out = [out stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
	return out;
}

+ (void) saveColors: (NSArray*) colors forKey: (NSString*)key
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[colors count]];
	for (NSColor *color in colors){
		[temp addObject:[NSArchiver archivedDataWithRootObject:color]];
	}
	[ud setObject: temp forKey:key];
}


+ (NSData*) archColorWithRed: (double) rd green: (double) gr blue: (double) bl
{
	NSColor *clr = [NSColor colorWithDeviceRed:rd green:gr blue:bl alpha:1.0];
	return [NSArchiver archivedDataWithRootObject:clr];
}
+ (NSData*) archColorWithHue: (double) hue saturation : (double) saturation brightness: (double) brightness
{
	NSColor *clr = [NSColor colorWithDeviceHue:hue saturation:saturation brightness:brightness alpha:1.0];
	return [NSArchiver archivedDataWithRootObject:clr];
}
+ (NSColor*) colorFromArch: (NSData*) data
{
	NSColor * aColor =nil;
	if (data != nil)
		aColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:data];
	return aColor;
}

+ (NSArray*) loadColorsForKey: (NSString*) key
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSArray *ary = [ud objectForKey:key];
    if (ary) {
        //NSLog(@"ary count = %d", [ary count]);
        NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:[ary count]];
        for (NSData *data in ary){
            if (data){
                [temp addObject:[Utility colorFromArch:data]];
            } else {
                [temp addObject:[NSColor whiteColor]];
            }
        }
        return temp;
    }
    return [NSArray new];
}

+ (NSString*) formatInterval: (NSTimeInterval) timeInt
{
    int sec = fmod(timeInt, 60.0);
    int min = timeInt / 60;
    int hrs = min / 60;
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hrs,min,sec];
}

+ (NSString*) applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:__APPNAME__];
}

@end
