//
//  IconsFile.m
//  Nudge
//
//  Created by Charles on 12/16/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "IconsFile.h"

#define FOUR 4

#import "IconData.h"


@implementation IconsFile
@synthesize iconLookup;
@synthesize data;
- (id) init
{
	NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:20];
	[temp addObject:[[IconData alloc] initWithName:@"ICON" size:[NSNumber numberWithInt:128] height:[NSNumber numberWithInt:32] description:@"32×32 1-bit mono icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"ICN#" size:[NSNumber numberWithInt:256] height:[NSNumber numberWithInt:32] description:@"32×32 1-bit mono icon with 1-bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"icm#" size:[NSNumber numberWithInt:24] height:[NSNumber numberWithInt:16] description:@"16×12 1 bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"icm4" size:[NSNumber numberWithInt:96] height:[NSNumber numberWithInt:16] description:@"16×12 4 bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"icm8" size:[NSNumber numberWithInt:192] height:[NSNumber numberWithInt:16] description:@"16×12 8 bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"ics#" size:[NSNumber numberWithInt:32] height:[NSNumber numberWithInt:16] description:@"16×16 1-bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"ics4" size:[NSNumber numberWithInt:128] height:[NSNumber numberWithInt:16] description:@"16×16 4-bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"ics8" size:[NSNumber numberWithInt:256] height:[NSNumber numberWithInt:16] description:@"16x16 8 bit icon"]];
	// is32 -- not in agreement w/ wikipedia
	[temp addObject:[[IconData alloc] initWithName:@"is32" size:[NSNumber numberWithInt:0] height:[NSNumber numberWithInt:16] description:@"16×16 24-bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"s8mk" size:[NSNumber numberWithInt:256] height:[NSNumber numberWithInt:16] description:@"16x16 8-bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"icl4" size:[NSNumber numberWithInt:512] height:[NSNumber numberWithInt:32] description:@"32×32 4-bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"icl8" size:[NSNumber numberWithInt:1024] height:[NSNumber numberWithInt:32] description:@"32×32 8-bit icon"]];
	// il32 -- not in agreement w/ wikipedia
	[temp addObject:[[IconData alloc] initWithName:@"il32" size:[NSNumber numberWithInt:0] height:[NSNumber numberWithInt:32] description:@"32x32 24-bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"l8mk" size:[NSNumber numberWithInt:1024] height:[NSNumber numberWithInt:32] description:@"32×32 8-bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"ich#" size:[NSNumber numberWithInt:288] height:[NSNumber numberWithInt:48] description:@"48×48 1-bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"ich4" size:[NSNumber numberWithInt:1152] height:[NSNumber numberWithInt:48] description:@"48×48 4-bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"ich8" size:[NSNumber numberWithInt:2304] height:[NSNumber numberWithInt:48] description:@"48×48 8-bit icon"]];
	// it32 -- not in agreement w/ wikipedia
	[temp addObject:[[IconData alloc] initWithName:@"ih32" size:[NSNumber numberWithInt:6912] height:[NSNumber numberWithInt:48] description:@"48×48 24-bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"h8mk" size:[NSNumber numberWithInt:2304] height:[NSNumber numberWithInt:48] description:@"48×48 8-bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"it32" size:[NSNumber numberWithInt:0] height:[NSNumber numberWithInt:128] description:@"128×128 24-bit icon"]];
	[temp addObject:[[IconData alloc] initWithName:@"t8mk" size:[NSNumber numberWithInt:16384] height:[NSNumber numberWithInt:128] description:@"128×128 8-bit mask"]];
	[temp addObject:[[IconData alloc] initWithName:@"ic08" size:[NSNumber numberWithInt:0] height:[NSNumber numberWithInt:256] description:@"256×256 icon in JPEG 2000 format"]];
	[temp addObject:[[IconData alloc] initWithName:@"ic09" size:[NSNumber numberWithInt:0] height:[NSNumber numberWithInt:512] description:@"512×512 icon in JPEG 2000 format"]];
	NSMutableDictionary *tempD = [[NSMutableDictionary alloc]initWithCapacity:[temp count]];
	for (IconData *idata in temp)
	{
		[tempD setObject:idata forKey: idata.name.copy];
	}
	iconLookup = [[NSDictionary alloc] initWithDictionary: tempD];
	return self;
}

- (void) loadIconData: (NSData*) iconData;
{
	data = iconData;
	int32_t totalLen;
	char buf[FOUR];
	char MAGIC[] = {'i','c','n','s'};
	// 1 -- check the stamp
	[data getBytes:buf length:FOUR];
	if (memcmp(buf,MAGIC, 4) != 0){
		NSLog(@"NO magic ICON");
		return;
	}
	unsigned int *pLength;
	pLength = malloc(4);
	*pLength = 0;
	NSRange totRange;
	totRange.location = 4;
	totRange.length = sizeof(totalLen);
	[data getBytes:pLength  range:totRange];
	totalLen = [self bytesToInt:(char*)pLength];
	int dataLen = [data length];
	NSAssert(totalLen == dataLen, @"incorrect length");
	int idx = 8;
	NSRange typeRange;
	NSRange lenRange;
	NSRange dataRange;
	typeRange.length = 4;
	lenRange.length = 4;
	do{
		typeRange.location = idx;
		lenRange.location = idx + 4;
		NSData *iconType = [data subdataWithRange:typeRange];
		NSString *respStr = [[NSString alloc]initWithData:iconType encoding:NSUTF8StringEncoding];
		NSLog(@"type= %@", respStr);
		IconData *meta = [iconLookup objectForKey:iconType];
		if (data == nil){
			NSLog(@"Unrecognized icon type: %@", iconType);
			return;
		}
		int metaLen = [meta.bytes intValue];
		unsigned int actualLen;
		[data getBytes: pLength range:lenRange];
		actualLen = [self bytesToInt:(char*)pLength];
		NSLog(@"len = %d", actualLen);
		if (metaLen > 0){
			NSAssert(metaLen ==  (actualLen - 8), @"icon lengths do not agree for type");
		}
		dataRange.location = idx+8;
		dataRange.length = actualLen - 8;
		meta.offset = idx+8;
		meta.length = actualLen-8;
		idx += actualLen;
	}while(idx < (totalLen -1));
	free(pLength);
}

- (int) bytesToInt: (char*) chars
{
	char buf[4];
	unsigned int *ret;
	ret = &buf;
	buf[0] = chars[3];
	buf[1] = chars[2];
	buf[2] = chars[1];
	buf[3] = chars[0];
	return ret[0];
}
- (NSData*) getIconForHeight: (int) height
{
	int maxSize = 0;
	NSRange range;
	NSString *best = nil;
	for (NSData *key in iconLookup) {
		IconData *iData = [iconLookup objectForKey:key];
		if ([iData.height intValue] == height && iData.offset != -1){
			if ([iData.bytes intValue] > maxSize) {
				best = iData.description.copy;
				range.location = iData.offset-8;
				range.length = iData.length+8;
			}
		}
	}
	if (best != nil) {
		return [data subdataWithRange: range];
	} 
	else {
		return nil;
	}
}
@end
