//
//  ResponseRESTHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 10/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "ResponseRESTHandler.h"


@implementation ResponseRESTHandler
@synthesize respBuffer;
@synthesize context;
@synthesize currentDict;
@synthesize target;
@synthesize callback;

- (id) initWithContext:(RTMProtocol*) ctx delegate: (NSObject*) tgt selector: (SEL) cb  
{
	if (self) 
	{
		respBuffer = [[NSMutableData alloc] init];
		context = ctx;
		[self setTarget: tgt];
		[self setCallback: cb];
	}
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [respBuffer setLength:0];
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
	
    // inform the user
    NSString *err = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSLocalizedRecoverySuggestionErrorKey]];
	if ([[error localizedDescription] rangeOfString: @"offline"].length > 0){
		// just log this error -- we are having connection problems
		//NSLog(@"%@", err);
	} else {
		[BaseInstance sendErrorToHandler:context.handler 
								   error: err 
								  module: context.module.name];
	}
	if (context.module.validationHandler){
		[context.module.validationHandler performSelector:@selector(validationComplete:) 
                                        withObject:[error localizedDescription]];
	}
	context.lastError = [error localizedDescription];
	[target performSelector: callback];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//	NSString *respStr = [[[NSString alloc] initWithData:respBuffer encoding:NSUTF8StringEncoding]autorelease];
	[self handleResponse:respBuffer];
	
}

-(void) handleResponse: (NSData*) respData
{
//	NSString *str = [[NSString alloc]initWithData: respData encoding: NSUTF8StringEncoding];
//	//NSLog(@"%@", str);
	[self doParse: respData];
	[self doCallback];
}
- (void) doParse: (NSData*) respStr
{
}

- (void) doCallback
{
	[target performSelector:callback];
}
@end
