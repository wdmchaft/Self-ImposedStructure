//
//  XMLParse.h
//  RTGTest
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XMLParse : NSObject  {
	NSXMLParser* parser;
	NSData* data;
	<NSXMLParserDelegate> parseDelegate;
}
@property (nonatomic, retain)  NSXMLParser* parser;
@property (nonatomic, retain)  NSData* data;
@property (nonatomic, retain)  <NSXMLParserDelegate> parseDelegate;
- (XMLParse*) initWithData: (NSData*) xmlData andDelegate: (<NSXMLParserDelegate>) xmlDelegate;
- (void)parseData;

@end
