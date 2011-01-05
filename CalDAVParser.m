//
//  CalDevParser.m
//  GCalModule
//
//  Created by Charles on 12/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalDAVParser.h"
#import "CalDAVParserDelegate.h"

@implementation CalDAVParser

@synthesize data;

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
		
		[scan scanUpToString:@"DESCRIPTION:" intoString:&ignore];
		[scan scanString:@"DESCRIPTION:" intoString:&ignore];
		NSString *descriptionStr = [NSString new];		
		[scan scanUpToString:@"LAST-MODIFIED:" intoString:&descriptionStr];
		if ([handler respondsToSelector: @selector(eventDescription:)]){
			[handler eventDescription: descriptionStr];
		}
		NSString *locationStr = [NSString new];
		[scan scanUpToString:@"LOCATION:" intoString:&ignore];
		[scan scanString:@"LOCATION:" intoString:&ignore];
		[scan scanUpToString:@"SEQUENCE:" intoString:&locationStr]			;
		if ([handler respondsToSelector: @selector(location:)]){
				[handler location: locationStr];
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
