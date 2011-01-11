//
//  ListHandler.m
//  RTGTest
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "ListsHandler.h"
#import "XMLParse.h"


@implementation ListsHandler

//- (ListsHandler*) initWithContext: (RTMModule*) ctx 
//{
//	if (self)
//	{
//		context.idMapping = [NSMutableDictionary new];
//	}
//	return self;
//}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
	
    if ( [elementName isEqualToString:@"list"]) {
        // addresses is an NSMutableArray instance variable
		NSString *id = [attributeDict objectForKey:@"id"];
		NSString *name = [attributeDict objectForKey:@"name"];
		if (context.idMapping == nil){
			context.idMapping = [[NSMutableDictionary new] retain];
		}
		[context.idMapping setObject: [[id copy]retain] forKey: [[name copy]retain]];
    }
}

- (void) doParse: (NSData*) respData
{
//	NSLog(@"%@", [[NSString alloc ]initWithData: respData encoding:NSUTF8StringEncoding]);
	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
	[parser parseData];	
}

- (void) doCallback
{
	[callback listsDone];
}

@end
