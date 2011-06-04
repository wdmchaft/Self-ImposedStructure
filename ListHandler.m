//
//  ListHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "ListHandler.h"
#import "XMLParse.h"
#import "Secret.h"
#import "Reporter.h"

@implementation ListHandler
@synthesize tempDictionary;
@synthesize temp;
@synthesize inputFormatter;

- (id) initWithContext:(RTMProtocol*) ctx delegate: (NSObject*) del selector: (SEL) cb 
{
	if ((self = (ListHandler*)[super initWithContext:ctx 
											delegate:del
											selector:cb])!= nil)
	{
		tempDictionary = [NSMutableDictionary new];
        inputFormatter = [NSDateFormatter new];
     	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [inputFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];   
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
		if (self.currentDict){
			[self addItem];
		}
		self.currentDict = [NSMutableDictionary new];
		[currentDict setObject:[context.module name] forKey:@"source"]; 
		[currentDict setObject:[context.module name] forKey:@"project"]; 
		[currentDict setObject:[[[NSString alloc] initWithString:context.listIdStr]retain] forKey:@"list_id"]; 
		[currentDict setObject:[[[NSString alloc] initWithString:id]retain] forKey:@"taskseries_id"]; 
		[currentDict setObject:[[[NSString alloc] initWithString:name]retain] forKey:TASK_NAME];
        NSString *modStr = [attributeDict objectForKey:@"modified"];
        if (modStr){
			NSDate *modDate = [inputFormatter dateFromString:modStr];
            [currentDict setObject:modDate forKey:@"modified"]; 
        }
        
		[currentDict setObject:context.module.name forKey:REPORTER_MODULE];
    }
	//
	// START ELEMENT: task (part of taskseries)
	// add the taskid to the dictionary
	//
	if ( [elementName isEqualToString:@"task"]) {
		NSString *id = [attributeDict objectForKey:@"id"];
		[currentDict setObject:[[[NSString alloc] initWithString:id]retain] forKey:@"task_id"]; 
        NSString *dueTimeStr = [attributeDict objectForKey:@"due"];
		BOOL hasDue = [dueTimeStr length]!=0;
        if (hasDue) {
            NSDate *dueDate = [inputFormatter dateFromString:dueTimeStr];
            [currentDict setObject:dueDate forKey:TASK_DUE];
		} 
		[currentDict setObject:[NSNumber numberWithInt:hasDue] forKey:@"has_due_time"];

    }
	//
	// START ELEMENT: task (part of taskseries)
	// add the taskid to the dictionary
	//
	if ( [elementName isEqualToString:@"note"]) {
		if (![currentDict objectForKey:@"note_id"]){
			NSString *id = [attributeDict objectForKey:@"id"];
			NSString *title = [attributeDict objectForKey:@"title"];
			[currentDict setObject:[[[NSString alloc] initWithString:id]retain] forKey:@"note_id"]; 
			[currentDict setObject:[[[NSString alloc] initWithString:title]retain] forKey:@"note_title"]; 
	        temp = [NSMutableString new];
		}
    }
	
//	if ( [elementName isEqualToString:@"list"]) {
//		NSString *id = [attributeDict objectForKey:@"id"];
//		listId = id; 
//    }
	if ( [elementName isEqualToString:@"err"]){
		//NSString* code = [attributeDict objectForKey:@"code"];
		NSString* msg = [attributeDict objectForKey:@"msg"];
	//	[BaseInstance sendErrorToHandler:context.handler error:msg module:[context name]];
        [context handleRTMError:[NSDictionary dictionaryWithObject:msg forKey:@"msg"]];
	}
	if ( [elementName isEqualToString:@"rrule"]){
        NSNumber *everyVal = [attributeDict objectForKey:@"every"];
        [currentDict setObject:everyVal forKey:@"every"];
        temp = [NSMutableString new];
    }
}

- (void)parser:(NSXMLParser *)parser 
didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
//	attributes:(NSDictionary *)attributeDict 
{
//	//NSLog(@"didEndElement for %@", elementName);
	//
	// END ELEMENT: taskseries
	// save the dictionary to the tasks dictionary
	//
    if ( [elementName isEqualToString:@"taskseries"]) {
		NSString *name = [self.currentDict objectForKey:@"name"];
		[tempDictionary setObject:self.currentDict forKey:name];
    }
    if ( [elementName isEqualToString:@"rrule"]){
        [currentDict setObject:[temp copy] forKey:@"rrule"];
        temp = nil;
    }
	if ( [elementName isEqualToString:@"note"]){
		if (![currentDict objectForKey:@"note_text"]){
			[currentDict setObject:[temp copy] forKey:@"note_text"];
		}
        temp = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (temp) {
        [temp appendString:string];
    }
}

- (void) doParse: (NSData*) respData
{
	//NSLog(@"%@", [[NSString alloc] initWithData: respData encoding:NSUTF8StringEncoding]);
	XMLParse *parser = [[XMLParse alloc]initWithData: respData andDelegate: self];
	[parser parseData];
	if (self.currentDict != nil && [self.currentDict count] > 0){
		[self addItem];
	}
	context.tasksDict = tempDictionary;
	context.tasksList = [NSMutableArray arrayWithArray:[tempDictionary allValues]];
}

//- (void) doCallback
//{
//	[callback listDone];
//}
@end
