//
//  TimelineHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/7/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "TimelineHandler.h"
#import "XMLParse.h"

@implementation TimelineHandler


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
	
	if ( [elementName isEqualToString:@"timeline"]) {
		context.timelineStr =  [[NSMutableString alloc] initWithCapacity:50];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	[context.timelineStr appendString:string];
}

- (void) handleResponse: (NSData*) respData
{
	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
	[parser parseData];
	[target performSelector:callback];
}


@end
