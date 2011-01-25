//
//  Utility.m
//  Nudge
//
//  Created by Charles on 11/22/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
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
		[timeDate setDateFormat: @"ddd' at 'hh:mm"];
		ret = [timeDate stringFromDate:date];
	}
	return ret;
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


@end
