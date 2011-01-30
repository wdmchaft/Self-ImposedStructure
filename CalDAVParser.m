//
//  CalDevParser.m
//  GCalModule
//
//  Created by Charles on 12/6/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "CalDAVParser.h"
#import "CalDAVParserDelegate.h"

@implementation CalDAVParser

@synthesize data;
- (void) descriptionIfExists: (NSString*) testStr target:(id) handler 
{
	NSRange descRange = [testStr rangeOfString:@"DESCRIPTION:"];
	if (descRange.location == NSNotFound)
		return;
	NSString *desc = [testStr substringFromIndex:descRange.location + descRange.length];
	[handler eventDescription:desc];
}

- (void) locationIfExists: (NSString*) testStr target:(id) handler 
{
	NSRange locRange = [testStr rangeOfString:@"LOCATION:"];
	if (locRange.location == NSNotFound)
		return;
	NSString *loc = [testStr substringFromIndex:locRange.location + locRange.length];
	[handler location:loc];
}

- (void)parse: (<CalDAVParserDelegate>) handler

{
	NSScanner *scan = [NSScanner localizedScannerWithString:data];
	NSString *ignore = [NSString new];
	[scan scanUpToString:@"BEGIN:VEVENT" intoString:&ignore];
	do{
		[handler beginEvent];
		[scan scanUpToString:@"DTSTART:" intoString:&ignore];
		[scan scanString:@"DTSTART:" intoString:&ignore];
		NSString *start = [NSString new];
		[scan scanUpToString:@"DTEND:" intoString:&start];
		if ([handler respondsToSelector: @selector(dateStart:)]){
			[handler dateStart:start];
		}
		[scan scanString:@"DTEND:" intoString:&ignore];
		NSString *end = [NSString new];
		[scan scanUpToString:@"DTSTAMP:" intoString:&end];
		if ([handler respondsToSelector: @selector(dateEnd:)]){
			[handler dateEnd:start];
		}
				
		[scan scanUpToString:@"LAST-MODIFIED:" intoString:&ignore];
		if ([handler respondsToSelector: @selector(eventDescription:)]){
			[self descriptionIfExists:ignore target: handler];
		}

		[scan scanUpToString:@"SEQUENCE:" intoString:&ignore]			;
		if ([handler respondsToSelector: @selector(location:)]){
			[self locationIfExists:ignore target:handler];
				[handler location: ignore];
		}
		[scan scanUpToString:@"SUMMARY:" intoString:&ignore];
		[scan scanString:@"SUMMARY:" intoString:&ignore];
		NSString *summaryStr = [NSString new];
		[scan scanUpToString:@"TRANSP" intoString:&summaryStr];
		if ([handler respondsToSelector: @selector(summary:)]){
			[handler summary: summaryStr];
		}
		if ([handler respondsToSelector: @selector(endEvent)]){
			[handler endEvent];
		}
	}
	while([scan scanUpToString:@"BEGIN:VEVENT" intoString:&ignore] == YES);	
		
}

@end
