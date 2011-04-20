//
//  XMLParse.h
//  selfstruct
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XMLParse : NSObject  {
	NSXMLParser* parser;
	NSData* data;
	id<NSXMLParserDelegate> parseDelegate;
}
@property (nonatomic, retain)  NSXMLParser* parser;
@property (nonatomic, retain)  NSData* data;
@property (nonatomic, retain)  id<NSXMLParserDelegate> parseDelegate;
- (XMLParse*) initWithData: (NSData*) xmlData andDelegate: (id<NSXMLParserDelegate>) xmlDelegate;
- (void)parseData;

@end
