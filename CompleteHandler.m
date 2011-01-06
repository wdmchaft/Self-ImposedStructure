//
//  CompleteHandler.m
//  RTGTest
//
//  Created by Charles on 11/9/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "CompleteHandler.h"
#import "XMLParse.h"


@implementation CompleteHandler
- (CompleteHandler*) initWithHandler:(<RTMCallback>) delegate 
{
	if (self =(CompleteHandler*)[super initWithContext:nil andDelegate:delegate])
	{
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
	
	if ( [elementName isEqualToString:@"task"]) {
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
}

- (void) doParse: (NSData*) respData
{
	NSLog(@"%@", [[NSString alloc] initWithData: respData encoding:NSUTF8StringEncoding]);
	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
	[parser parseData];	
}

- (void) doCallback
{
	[callback rmDone];
}
@end
