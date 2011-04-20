//
//  TokenHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "TokenHandler.h"


@implementation TokenHandler


- (void) doParse: (NSData*) respData
{
	NSString *respStr = [[NSString alloc]initWithData: respData encoding:NSUTF8StringEncoding];
	NSRange tokenRange; 
	NSRange tokenStart = [respStr rangeOfString:@"<token>"];
	if (tokenStart.location == NSNotFound){
	}
	else {
		NSRange tokenEnd = [respStr rangeOfString:@"</token>"];
		tokenRange.location = tokenStart.location + tokenStart.length;
		tokenRange.length = tokenEnd.location - tokenRange.location;
		NSString *token = [respStr substringWithRange:tokenRange];
		context.tokenStr = [[[NSString alloc] initWithString: token]retain];	
	}
	
}

- (void) doCallback
{
	[callback tokenDone];
}
@end
