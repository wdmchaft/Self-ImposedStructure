//
//  RequestREST.m
//  CocoaTest
//
//  Created by Charles on 10/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "RequestREST.h"
#import "Utility.h"


@implementation RequestREST


- (NSString*) createURLWithFamily: (NSString*) fam usingSecret: (NSString*) secret andParams: (NSDictionary*) params
{
	NSString *fmt = [[[NSString alloc]initWithFormat:@"http://api.rememberthemilk.com/services/%@/", fam,nil ]autorelease];
	NSString *apiSig = [self createSigFromSecret:secret andParams: params];
	NSString *urlStr = [[[NSString alloc]initWithFormat: fmt, nil]autorelease];
	if (params){
		NSArray *keys = [params allKeys];
		NSArray *sorted = [keys sortedArrayUsingComparator:^(id obj1, id obj2) {
			NSString *objName = (NSString*) obj1;
			NSString *obj2Name = (NSString*) obj2;
			NSComparisonResult result = [objName compare:obj2Name options:NSNumericSearch | NSCaseInsensitiveSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch range:NSMakeRange(0, [objName length]) locale:[NSLocale currentLocale]];
			return result;
		}];
		
		for (int i =0; i < [sorted count]; i++) {
			NSString *key = [sorted objectAtIndex: i];
			
			id value = [params valueForKey:key];
			if ([value isKindOfClass:[NSString class]]){
				value = [Utility encode:value];
			}
			NSString *sep = i == 0 ? @"?" : @"&";
			urlStr = [urlStr stringByAppendingFormat:@"%@%@=%@", sep, key, value, nil]; 
		}
	}
	urlStr = [urlStr stringByAppendingFormat:@"&api_sig=%@", apiSig];
	//NSLog(@"urlStr= %@", urlStr);
	return urlStr;
}

-(NSString*) createSigFromSecret: (NSString*)secret andParams:(NSDictionary*) dict
{

	NSString *ret = [[[NSString alloc] initWithString:secret] autorelease];
	NSArray *keys = [dict allKeys];
	NSArray *sorted = [keys sortedArrayUsingComparator:^(id obj1, id obj2) {
		NSString *objName = (NSString*) obj1;
		NSString *obj2Name = (NSString*) obj2;
		NSComparisonResult result = [objName compare:obj2Name options:NSNumericSearch | NSCaseInsensitiveSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch range:NSMakeRange(0, [objName length]) locale:[NSLocale currentLocale]];
		return result;
	}];
	for (int i = 0; i < [sorted count];i++) {
		NSString *key = [sorted objectAtIndex:i];
		NSString *val = [dict objectForKey:key];
		ret = [ret stringByAppendingFormat:@"%@%@", key, val, nil];
	}
	ret = [self doMD5:ret];
	return ret;
}

-( NSString*) doMD5: (NSString *) str{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], 
			 result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11],
			 result[12], result[13],result[14],result[15],nil] lowercaseString];
}

- (NSURLConnection*) sendRequestWithURL: (NSString*) urlStr andHandler:(<ResponseHandler>) handler
{
	//NSLog(@"sendRequestWithURL for %@", urlStr);
	NSURL *url = [[[NSURL alloc]initWithString:urlStr]autorelease];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:url];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:handler];
	if (!theConnection) {
		// Inform the user that the connection failed.
		return nil;
	}
	return theConnection;
}



- (void) dealloc
{
	[super dealloc];
}
@end
