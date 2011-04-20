//
//  GMailRequestHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "GMailRequestHandler.h"
#import "XMLParse.h"
#import "Reporter.h"

@protocol CallBack
- (void) didFinishRequest: (GMailRequestHandler*) rHandler;
@end

@implementation GMailRequestHandler

@synthesize respBuffer, titleStr,summaryStr,idStr,nameStr, emailStr, issuedDate, modifiedDate,
highestTagValue,minTagValue,hrefStr,rules, alertHandler, validationHandler, timeStampFormatter;
@synthesize msgDict;
@synthesize callback;
@synthesize bufferStr;

- (void) initInternal 
{
	respBuffer = [NSMutableData new];
	titleStr = [NSString new];
	summaryStr = [NSString new];
	hrefStr = [NSString new];
	nameStr = [NSString new];
	emailStr = [NSString new];
	msgDict = [NSMutableDictionary new];
}

-(id) initForValidation: (NSObject*) delegate {
	if (self)
	{
		[self initInternal];;
		validationHandler = delegate ;
	}
	return self;
}

-(id) initWithTagValue: (NSNumber*) tagValue 
				 rules: (NSArray*) inRules 
			   handler: (<AlertHandler>) handler
			  delegate: (NSObject*) delegate;
{
	if (self)
	{
		[self initInternal];
		minTagValue =  tagValue; // this is shared
		highestTagValue = [tagValue copy]; // this is not
		rules = inRules;
		alertHandler = handler;
		callback = delegate;
		//NSLog(@"mintagval = %qi", minTagValue.longLongValue);
	}
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//	if ([response isKindOfClass: [NSHTTPURLResponse class]] == YES){
	//		NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
	//	}
    [respBuffer setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
	
	[self.respBuffer appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	
    [connection release];
	
    NSString *err = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
					 [error localizedDescription],
					 [[error userInfo] objectForKey:NSLocalizedRecoverySuggestionErrorKey]];
	if ([[error localizedDescription] rangeOfString: @"offline"].length > 0){
		// just log this error -- we are having connection problems
		NSLog(@"%@", err);
	} else {
		if (alertHandler){
			[BaseInstance sendErrorToHandler: alertHandler error: err module: ((<Instance>)callback).name];
		}
	}
	if (validationHandler){
		[validationHandler performSelector:@selector(validationComplete:) 
									  withObject:[error localizedDescription]];
	}
	//[refreshTimer invalidate];
}

-(NSNumber*) getIdTagValue: (NSString*) tag
{
	NSAssert([tag length] < 100, @"ID is too long");
	NSArray *comps = [tag componentsSeparatedByString:@":"];
	int compsCount = [comps count];
	NSString *number = [comps objectAtIndex:compsCount - 1];
	//	NSLog(@"id number = %@", number);
	return [NSNumber numberWithLongLong:number.longLongValue];
}

- (void) addEntry
{
	NSNumber *tagVal = [self getIdTagValue: idStr];
	
//	if (tagVal.longLongValue > minTagValue.longLongValue) {
		long long val = tagVal.longLongValue - minTagValue.longLongValue;
		//NSLog(@"val = %qi", val);
		if (tagVal.longLongValue > highestTagValue.longLongValue){
	
			highestTagValue = tagVal;
		}
		NSDictionary *entryDict = [[NSDictionary alloc]initWithObjectsAndKeys:
								   ((<Instance>)callback).name, REPORTER_MODULE,
								   summaryStr,MAIL_SUMMARY,
								   titleStr, MAIL_SUBJECT,
								   nameStr, MAIL_NAME,
								   emailStr, MAIL_EMAIL,
								   hrefStr, @"href",
								   modifiedDate, @"modified",
								   issuedDate, MAIL_ARRIVAL_TIME,
								   nil];
		[msgDict setObject:entryDict forKey: titleStr];	
//	}
	
}
#define AUTHERR @"<HEAD>\n<TITLE>Unauthorized</TITLE>\n</HEAD>"
#define SUCCESSSTR @"<tagline>New messages in your Gmail Inbox</tagline>"

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *respStr = [[[NSString alloc] initWithData:respBuffer encoding:NSUTF8StringEncoding]autorelease];
	//NSLog(@"%@",respStr);
	// look for errors now
	NSRange successRange = [respStr rangeOfString:SUCCESSSTR];

	if (successRange.location == NSNotFound){
		// Some failure occurred
		NSLog(@"%@",respStr);
		NSString *errStr = @"Unknown error occurred see log for details";
		NSRange authRange = [respStr rangeOfString:AUTHERR];
		
		if (authRange.location != NSNotFound){
			errStr = @"Gmail account fails to authenticate.  (Perhaps retry password.)";
		}
		if (!validationHandler){
			[BaseInstance sendErrorToHandler:alertHandler 
									   error:errStr
									  module:[((id<Instance>)callback) name]];
			return;
		} else {
			[validationHandler performSelector:@selector(validationComplete:) 
									withObject:errStr];		
		}
	} 
	else if (validationHandler){
		[validationHandler performSelector:@selector(validationComplete:) 
								withObject:nil];
	}
	
	msgDict = [NSMutableDictionary new];
	XMLParse *parser = [[XMLParse alloc]initWithData: respBuffer andDelegate: self];
	[parser parseData];
	if (titleStr != nil) {
		[self addEntry];
	}
	
	NSString *key = nil;
	NSDictionary *item = nil;
	for (key in msgDict){
		item = [msgDict objectForKey: key];	
        NSColor *color;
		FilterResult res = [FilterRule processFilters:rules forMessage: msgDict color:&color];
		if (res != RESULT_IGNORE) {
			WPAAlert *alert = [[WPAAlert alloc]init];
			alert.moduleName = ((id<Instance>)callback).name;
			alert.title =key;
			alert.message=[item objectForKey:@"summary"];
			alert.sticky = (res == RESULT_IMPORTANT);
			alert.urgent = (res == RESULT_IMPORTANT);
			alert.params = item;
			
			[alertHandler handleAlert:alert];
		}
	}
	if (highestTagValue.longLongValue > minTagValue.longLongValue){
		minTagValue = [highestTagValue copy];
	//	[super saveDefaultValue: minTagValue forKey: MINTAGVALUE];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[BaseInstance sendDone: alertHandler module: callback.description];
	[((id<CallBack>)callback) didFinishRequest: self];
}
 
 - (void)parser:(NSXMLParser *)parser 
					  didEndElement:(NSString *)elementName 
					   namespaceURI:(NSString *)namespaceURI 
					  qualifiedName:(NSString *)qName 
{
	// End Element Processing
    if ( [elementName isEqualToString:@"entry"]) {
		[self addEntry];
	}
    else if ( [elementName isEqualToString:@"title"]) {
		titleStr = bufferStr;
    } else if ( [elementName isEqualToString:@"summary"]) {
		summaryStr = bufferStr;
    } else if ( [elementName isEqualToString:@"id"]) {
		idStr = bufferStr;
	} else if ( [elementName isEqualToString:@"name"]){
		nameStr = bufferStr;
	} else if ( [elementName isEqualToString:@"email"]){
		emailStr = bufferStr;
	} else if ( [elementName isEqualToString:@"issued"]){
		issuedDate = [self dateFromTimeStamp:bufferStr];
	} else if ( [elementName isEqualToString:@"modified"]){
		modifiedDate = [self dateFromTimeStamp:bufferStr];
	}

}

- (NSDate*) dateFromTimeStamp:(NSString*)stamp{
	if (timeStampFormatter == nil){
		timeStampFormatter = [[NSDateFormatter alloc] init];
		[timeStampFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[timeStampFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	}
	return [timeStampFormatter dateFromString:stamp]; 
}

 - (void)parser:(NSXMLParser *)parser 
					didStartElement:(NSString *)elementName 
					   namespaceURI:(NSString *)namespaceURI 
					  qualifiedName:(NSString *)qName 
						 attributes:(NSDictionary *)attributeDict 
{
	if ([elementName isEqualToString:@"link"]){
		hrefStr=[attributeDict objectForKey:@"href"];
	}
	bufferStr = [NSString new];
}
 
 - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	 
	 bufferStr = [bufferStr stringByAppendingString:string];	
 }

@end
