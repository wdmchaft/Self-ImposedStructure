//
//  CalDevParser.m
//  GCalModule
//
//  Created by Charles on 12/6/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "MimeHandler.h"
#import "Utility.h"
/* 
 ugly inefficient code to try to niggle a plain-text synopsis out of MIME messages
 */

@implementation MimeHandler
+ (NSString*)synopsis: (NSString*) data
{
	NSRange range; range.location = NSNotFound;
	range = [data rangeOfString:@"Content-type: multipart" options:NSCaseInsensitiveSearch];
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
	NSRange start = [data rangeOfString:@"\nContent-type: text/plain" options:NSCaseInsensitiveSearch];
	if (start.location == NSNotFound) {
		return @"";
	}
	NSString *partStart = [data substringFromIndex:start.location + start.length];
	unsigned int endLoc = [MimeHandler findEnd: partStart withBoundaries: boundaries]; 
	NSString *srchStr = [partStart substringToIndex:endLoc];
	NSRange sstart = [srchStr rangeOfString:@"\n\n"];
	NSString *ret = [srchStr substringFromIndex:sstart.location +sstart.length];
	ret = [ret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSUInteger maxLen = [ret length] > 100 ? 100 : [ret length];
	return [ret substringToIndex:maxLen];
}

// find all the "Content-type: multipart" headers and associated boundary strings
+ (NSArray*) getBoundaries: (NSString*) data
{
	NSString *sData = data;
	NSMutableArray *ret = [NSMutableArray new];
	NSRange range;
	range.location = NSNotFound;
	range = [sData rangeOfString:@"\nContent-type: multipart/" options:NSCaseInsensitiveSearch];
	while (range.location != NSNotFound) {
		// find boundary
		NSInteger pt1 = range.location + range.length;
		NSString *srchStr = [sData substringFromIndex:range.location + range.length];
		NSString *boundary = nil;
		NSUInteger endBoundary = [MimeHandler getBoundaryFrom:srchStr ret:&boundary];

	//	NSLog(@"boundary=%@",boundary);
		[ret addObject:boundary];
//		NSInteger pt2 = pt1 + eRange.location + eRange.length;
		NSInteger pt2 = pt1 + endBoundary;
		sData = [sData substringFromIndex:pt2];
		range = [sData rangeOfString: @"\nContent-type: multipart/" options:NSCaseInsensitiveSearch];
		if (range.location != NSNotFound){
	//		NSLog(@"looping...");
		}
	}
	return [ret count] == 0 ? nil : ret;	
}

+ (NSUInteger) getBoundaryFrom:(NSString*) srchStr ret:(NSString**) retString
{
	NSRange srchRange, bRange, eRange, tRange;
	
	BOOL quoted = [MimeHandler isQuotedBoundary: srchStr];
	NSString *eTarget = quoted ? @"\"\n" : @"\n";
	NSString *bTarget = quoted ? @"Boundary=\"" : @"Boundary=";
	bRange = [srchStr rangeOfString:bTarget options:NSCaseInsensitiveSearch];
	srchRange.location=bRange.location+bRange.length;
	srchRange.length = [srchStr length] - srchRange.location;
	eRange = [srchStr rangeOfString:eTarget options:0 range:srchRange]; 
	tRange.location = bRange.location + bRange.length;
	tRange.length = eRange.location - tRange.location;
	NSString *boundary = [NSString	stringWithString:[srchStr substringWithRange:tRange]];
	*retString = boundary;
	return eRange.location + eRange.length;
}

+ (BOOL) isQuotedBoundary: (NSString*) srchStr
{
	// if its quoted we will find both of these in the same place --
	// only return false if rangeN is less than rangeQ
	NSRange bRangeQ = [srchStr rangeOfString:@"Boundary=\"" options:NSCaseInsensitiveSearch];
	NSRange bRangeN = [srchStr rangeOfString:@"Boundary=" options:NSCaseInsensitiveSearch];
	return (bRangeN.location >= bRangeQ.location) ;
}

+ (NSString*)synopsisFromSimple: (NSString*) data
{
//	NSLog(@"data = %@",data);
	NSString* encodeStr = @"Content-Transfer-Encoding: base64";
	NSRange encodeRange = [data rangeOfString:encodeStr options:NSCaseInsensitiveSearch];
	BOOL decodeIt = encodeRange.location != NSNotFound;
	
	NSRange boundaryRange = [data rangeOfString:@"\n\n"];
//	NSLog(@"location = %d length = %d", boundaryRange.location,boundaryRange.length);
	NSString *synopsis = [data substringFromIndex:boundaryRange.location + boundaryRange.length];
	if (decodeIt) {
		NSData *data = [Utility dataByBase64DecodingString:synopsis];
		synopsis = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	synopsis = [synopsis stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSUInteger maxLen = [synopsis length] > 100 ? 100 : [synopsis length];
	return [synopsis substringToIndex:maxLen];
}

@end
