//
//  CompleteHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/9/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "CompleteRespHandler.h"
#import "XMLParse.h"


@implementation CompleteRespHandler
@synthesize route;
- (id) initWithContext:(RTMProtocol*) ctx delegate: (NSObject*) tgt selector: (SEL) cb  
 route: (RouteInfo*) info
{
	self = [super initWithContext:ctx delegate: tgt selector:cb];
	if (self)
	{
		[self setRoute:info];
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{

	if ( [elementName isEqualToString:@"rsp"]){
		NSString *status =[[attributeDict objectForKey:@"stat"] copy];
		BOOL ok = [status isEqualToString:@"ok"];
		[route setOk:ok];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
}

- (void) doParse: (NSData*) respData
{
//	//NSLog(@"%@", [[NSString alloc] initWithData: respData encoding:NSUTF8StringEncoding]);
	currentDict = [NSMutableDictionary new];
	[route setOk: NO];
	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
	[parser parseData];	
}

- (void) doCallback
{
	[target performSelector:callback withObject:route ];
}
@end
