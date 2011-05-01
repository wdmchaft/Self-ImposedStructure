//
//  FrobHandler.m
//  CocoaTest
//
//  Created by Charles on 10/30/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "FrobHandler.h"
#import "RTMModule.h"


@implementation FrobHandler

- (void) doParse: (NSData*) respData
{
	NSString *respStr = [[NSString alloc]initWithData:respData encoding:NSUTF8StringEncoding];
	NSRange frobRange; 
	NSRange frobStart = [respStr rangeOfString:@"<frob>"];
	if (frobStart.location == NSNotFound){
	}
	else {
		NSRange frobEnd = [respStr rangeOfString:@"</frob>"];
		frobRange.location = frobStart.location + frobStart.length;
		frobRange.length = frobEnd.location - frobRange.location;
		NSString *frob = [respStr substringWithRange:frobRange];
		context.frobStr = [[NSString alloc] initWithString: frob];	
	}
}

-(void) handleResponse:(NSData *)respStr
{
	[super handleResponse:respStr];
}

- (void) doCallback
{
	[super doCallback];
}
@end
