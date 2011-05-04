//
//  RefreshHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "RefreshHandler.h"
#import "XMLParse.h"


@implementation RefreshHandler
- (id) initWithContext:(RTMProtocol*) ctx delegate: (NSObject*) del selector: (SEL) cb  {
	return [super initWithContext:ctx delegate:del selector:cb];
}
//- (RefreshHandler*) initWithContext: (RTMProtocol*) ctx
//{
//	self = (RefreshHandler*)[super initWithContext:ctx];
//
//	return self;
//}

//- (void) handleResponse: (NSData*) respData
//{
//	//NSLog(@"%@", [[NSString alloc] initWithData: respData encoding:NSUTF8StringEncoding]);
//	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
//	[parser parseData];
//	
//}

//- (void) doCallback
//{
//	[ctx.module performSelector:ctx.callback];
//}
@end
