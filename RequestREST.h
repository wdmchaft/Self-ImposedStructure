//
//  RequestREST.h
//  CocoaTest
//
//  Created by Charles on 10/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"
#import "FrobHandler.h"
#import <CommonCrypto/CommonDigest.h>


@interface RequestREST : NSObject {

}


-(NSString*) createSigFromSecret: (NSString*)secret 
					   andParams:(NSDictionary*) dict;
-( NSString*) doMD5: (NSString *) str;

- (NSString*) createURLWithFamily: (NSString*) fam 
					  usingSecret: (NSString*) secret 
						andParams: (NSDictionary*) params;

- (NSURLConnection*) sendRequestWithURL: (NSString*) url 
							 andHandler:(ResponseRESTHandler*) handler;

@end
