//
//  ClientLoginHandler.m
//  Nudge
//
//  Created by Charles on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ClientLoginHandler.h"


@implementation ClientLoginHandler
@synthesize caller;
@synthesize respBuffer;

- (id) initWithCallback:(id) callback{
	if (self)
	{
		caller = callback;
		respBuffer = [NSMutableData new];
	}
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response isKindOfClass: [NSHTTPURLResponse class]] == YES){
		NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
		NSLog(@"code = %d",[httpResp statusCode]);
		if ([httpResp statusCode] != 200)
		{
			[caller clientLoginError:[NSString stringWithFormat:@"Google status code = %d", [httpResp statusCode]]];
		}
//		NSDictionary *respDict = [httpResp allHeaderFields];
//		for (NSString *key in respDict){
//			NSLog(@"%@ = [%@]", key, [respDict objectForKey:key]);
//		}
		[respBuffer setLength:0];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
	
	[self.respBuffer appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	
    [connection release];
	
    NSString *err = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
					 [error localizedDescription],
					 [[error userInfo] objectForKey:NSLocalizedRecoverySuggestionErrorKey]];
	[caller clientLoginError:err];
	NSLog(@"%@", err);
	//[refreshTimer invalidate];
}


#define ERRSTR @"<HEAD>\n<TITLE>Unauthorized</TITLE>\n</HEAD>"

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *respStr = [[[NSString alloc] initWithData:respBuffer encoding:NSUTF8StringEncoding]autorelease];
	
	NSLog(@"%resp=[%@]", [[NSString alloc] initWithData: respBuffer encoding:NSUTF8StringEncoding]);

	// look for errors now
	NSRange okRange = [respStr rangeOfString:@"Auth="];
	
	if (okRange.location == NSNotFound){
		// Authentication failure occurred

			NSLog(@"AUTHENTICATION FAILURE ");
		[caller clientLoginError:[NSString stringWithFormat:@"Bad clientLogin Response: [%@]",respStr]];
		
	} 
	else {
		NSRange tokenRange;
		tokenRange.location=okRange.location +5;
		NSInteger respLen = [respStr length];
		tokenRange.length=(respLen - tokenRange.location) - 1;
		NSString *token=[respStr substringWithRange:tokenRange];
		NSLog(@"token=[%@]", token);
		[caller clientLoginSuccess: token];
	}

	

}


@end
