//
//  Utility.m
//  Nudge
//
//  Created by Charles on 11/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
    long outputLength = BIO_get_mem_data(context, &outputBuffer);
    NSString *encodedString = [NSString
							   stringWithCString:outputBuffer encoding: NSUTF8StringEncoding];
							//   length:outputLength];
	int len = [encodedString length];
	encodedString = [encodedString substringToIndex:len-1];
    BIO_free_all(context);
	
    return encodedString;
}
@end
