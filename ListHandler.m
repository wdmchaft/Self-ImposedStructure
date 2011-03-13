//
//  ListHandler.m
//  RTGTest
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "ListHandler.h"
#import "XMLParse.h"
#import "Secret.h"
#import "Reporter.h"

@implementation ListHandler
@synthesize tempList;
@synthesize tempDictionary;;

- (ListHandler*) initWithContext: (RTMModule*) ctx andDelegate: (id<RTMCallback>) delegate
{
	if ((self = (ListHandler*)[super initWithContext:ctx andDelegate:delegate])!= nil)
	{
		tempList = [NSMutableArray new];
		tempDictionary = [NSMutableDictionary new];
		//context.tasksList = [NSMutableArray new];
		//context.tasksDict = [NSMutableDictionary new];
	}
	return self;
}
- (void) addItem
{
	NSString *name = [[NSString alloc] initWithString:[currentDict objectForKey:@"name"]];
	[context.tasksDict setObject:self.currentDict forKey:name];
	//[currentDict removeObjectForKey:@"name"];
	self.currentDict = nil;
}
- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
	//
	// START ELEMENT: taskseries
	// create a new dictionary
	//
    if ( [elementName isEqualToString:@"taskseries"]) {
		NSString *name = [attributeDict objectForKey:@"name"];
		NSString *id = [attributeDict objectForKey:@"id"];
		[tempList addObject:name];
		if (self.currentDict){
			[self addItem];
		}
		self.currentDict = [NSMutableDictionary new];
		[currentDict setObject:[[[NSString alloc] initWithString:listId]retain] forKey:@"list_id"]; 
		[currentDict setObject:[[[NSString alloc] initWithString:id]retain] forKey:@"taskseries_id"]; 
		[currentDict setObject:[[[NSString alloc] initWithString:name]retain] forKey:TASK_NAME]; 
		[currentDict setObject:context.name forKey:REPORTER_MODULE];
    }
	//
	// START ELEMENT: task (part of taskseries)
	// add the taskid to the dictionary
	//
	if ( [elementName isEqualToString:@"task"]) {
		NSString *id = [attributeDict objectForKey:@"id"];
		NSString *hasDueTimeStr = [attributeDict objectForKey:@"has_due_time"];
		[currentDict setObject:[[[NSString alloc] initWithString:id]retain] forKey:@"task_id"]; 
		if ([hasDueTimeStr isEqualToString:@"1"]){
			NSString *dueTimeStr = [attributeDict objectForKey:@"due"];
			NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
			[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			[inputFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
			NSDate *dueDate = [inputFormatter dateFromString:dueTimeStr];
			[currentDict setObject:dueDate forKey:TASK_DUE];
		} else {
			[currentDict setObject:[NSDate distantFuture] forKey:TASK_DUE];
		}
    }
	if ( [elementName isEqualToString:@"list"]) {
		NSString *id = [attributeDict objectForKey:@"id"];
		listId = id; 
    }
	if ( [elementName isEqualToString:@"err"]){
		//NSString* code = [attributeDict objectForKey:@"code"];
		NSString* msg = [attributeDict objectForKey:@"msg"];
		[BaseInstance sendErrorToHandler:context.handler error:msg module:[context name]];
	}
	
}
- (void)parser:(NSXMLParser *)parser 
didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
//	attributes:(NSDictionary *)attributeDict 
{
//	NSLog(@"didEndElement for %@", elementName);
	//
	// END ELEMENT: taskseries
	// save the dictionary to the tasks dictionary
	//
    if ( [elementName isEqualToString:@"taskseries"]) {
		NSString *name = [self.currentDict objectForKey:@"name"];
		[tempDictionary setObject:self.currentDict forKey:name];
    }
}
- (void) doParse: (NSData*) respData
{
//	NSLog(@"%@", [[NSString alloc] initWithData: respData encoding:NSUTF8StringEncoding]);
	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
	[parser parseData];
	if (self.currentDict != nil && [self.currentDict count] > 0){
		[self addItem];
	}
	context.tasksDict = tempDictionary;
	context.tasksList = tempList;
}

- (void) doCallback
{
	[callback listDone];
}
@end
