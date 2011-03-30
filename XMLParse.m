//
//  XMLParse.m
//  RTGTest
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "XMLParse.h"


@implementation XMLParse
@synthesize parser;
@synthesize parseDelegate;
@synthesize data;

- (XMLParse*) initWithData: (NSData*) xmlData andDelegate: (id<NSXMLParserDelegate>) xmlDelegate
{
	if (self) 
	{
		data = xmlData;
		parseDelegate = xmlDelegate;
		parser = [[NSXMLParser alloc] initWithData:xmlData];
		[parser setDelegate:(id<NSXMLParserDelegate>)parseDelegate];
		[parser setShouldResolveExternalEntities:YES];
	}
	return self;
}

- (void)parseData {
    BOOL success;
    if (parser) {
		success = [parser parse]; // return value not used
	}
	// if not successful, delegate is informed of error
}

@end
