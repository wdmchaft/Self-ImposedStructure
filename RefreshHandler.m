//
//  RefreshHandler.m
//  RTGTest
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RefreshHandler.h"
#import "XMLParse.h"


@implementation RefreshHandler

- (RefreshHandler*) initWithContext: (RTMModule*) ctx andDelegate: (<RTMCallback>) delegate 
{
	self = (RefreshHandler*)[super initWithContext:ctx andDelegate: delegate];

	return self;
}

//- (void) handleResponse: (NSData*) respData
//{
//	NSLog(@"%@", [[NSString alloc] initWithData: respData encoding:NSUTF8StringEncoding]);
//	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
//	[parser parseData];
//	
//}

- (void) doCallback
{
	[callback refreshDone];
}
@end
