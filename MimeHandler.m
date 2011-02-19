//
//  CalDevParser.m
//  GCalModule
//
//  Created by Charles on 12/6/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "MimeHandler.h"

@implementation MimeHandler
+ (NSString*)synopsis: (NSString*) data
{
	NSRange range; range.location = NSNotFound;
	range = [data rangeOfString:@"Content-type: multipart"];
	if (range.location == NSNotFound){
		return [MimeHandler synopsisFromSimple: data];
	} else {
		return [MimeHandler synopsisFromMultiPart: data];
	}
}

+ (NSInteger) findEnd: (NSString*) data withBoundaries: (NSArray*) boundaries
{
	NSRange ret;
	ret.location = NSNotFound;
	for (NSString *boundary in boundaries) {
		NSRange test = [data rangeOfString:boundary];
		if (test.location < ret.location){
			ret.location = test.location;
		}
	}
	return ret.location;
}

+ (NSString*) synopsisFromMultiPart: (NSString*) data
{
	// first find any boundary strings
	NSArray *boundaries = [MimeHandler getBoundaries: data];
	
	// now look for a plain text part of the message
	NSRange start = [data rangeOfString:@"\nContent-type: text/plain"];
	if (start.location == NSNotFound) {
		return @"";
	}
	NSString *partStart = [data substringFromIndex:start.location + start.length];
	unsigned int endLoc = [MimeHandler findEnd: partStart withBoundaries: boundaries]; 
	NSString *srchStr = [partStart substringToIndex:endLoc];
	NSRange sstart = [srchStr rangeOfString:@"\n\n"];
	NSString *ret = [srchStr substringFromIndex:sstart.location +sstart.length];
	return ret = [ret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// find all the "Content-type: multipart" headers and associated boundary strings
+ (NSArray*) getBoundaries: (NSString*) data
{
	NSString *sData = data;
	NSMutableArray *ret = [NSMutableArray new];
	NSRange range;
	range.location = NSNotFound;
	range = [sData rangeOfString:@"\nContent-type: multipart/"];
	while (range.location != NSNotFound) {
		// find boundary
		NSInteger pt1 = range.location + range.length;
		NSString *srchStr = [sData substringFromIndex:range.location + range.length];
		NSRange bRange = [srchStr rangeOfString:@"Boundary=\""];
		NSRange eRange = [srchStr rangeOfString:@"\"\n"];
		NSRange tRange; 
		tRange.location = bRange.location + bRange.length;
		tRange.length = eRange.location - tRange.location;
		NSString *boundary = [srchStr substringWithRange:tRange];
		[ret addObject:boundary];
		NSInteger pt2 = pt1 + eRange.location + eRange.length;
		sData = [sData substringFromIndex:pt2];
		range = [sData rangeOfString: @"\nContent-type: multipart/"];
	}
	return [ret count] == 0 ? nil : ret;	
}

+ (NSString*)synopsisFromMultiPartA: (NSString*) data
{
	NSString *BOUNDARY=@"boundary=";
	NSScanner *scan = [NSScanner localizedScannerWithString:data];
	NSString *ignore;
	[scan scanUpToString:@"Content-Type:" intoString:&ignore];
	[scan scanUpToString:BOUNDARY intoString:&ignore];
	NSString *boundary = nil;
	[scan scanUpToString:@"\n" intoString:&boundary];
	if (!boundary) {
		NSLog(@"no boundary");
	}
	boundary = [boundary substringFromIndex:[BOUNDARY length]];
	NSString *target2 = [NSString stringWithFormat:@"--%@\n",boundary];
	NSString *target1 = [NSString stringWithFormat:@"%@Content-Type: text/plain",target2];
	[scan scanUpToString:target1 intoString:&ignore];
	[scan scanUpToString:@"\n\n" intoString:&ignore];
	NSString *synopsis;
	[scan scanUpToString:target2 intoString:&synopsis];
	return [synopsis substringToIndex:100];
}

+ (NSString*)synopsisFromSimple: (NSString*) data
{
	
	NSRange boundaryRange = [data rangeOfString:@"\n\n"];
	NSString *synopsis = [data substringFromIndex:boundaryRange.location + boundaryRange.length];
	return [synopsis substringToIndex:100];
}

@end
