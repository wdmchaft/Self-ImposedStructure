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
@synthesize timeLine;
- (TimelineHandler*) initWithHandler:(<RTMCallback>) delegate 
{
	if (self =(TimelineHandler*)[super initWithContext:nil andDelegate:delegate])
	{
		timeLine = [NSMutableString new];
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
	
	if ( [elementName isEqualToString:@"timeline"]) {
		timeLine =  [[NSMutableString alloc] initWithCapacity:50];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	[timeLine appendString:string];
}

- (void) handleResponse: (NSData*) respData
{
	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
	[parser parseData];
	[callback timelineDone];
	
}


@end
