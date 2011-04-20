//
//  IconData.m
//  Nudge
//
//  Created by Charles on 12/17/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "IconData.h"


@implementation IconData
@synthesize name;
@synthesize bytes;
@synthesize description; 
@synthesize height;
@synthesize offset;
@synthesize length;

-(id)initWithName:(NSString*)_name size: (NSNumber*) _size height: (NSNumber*) _height description: (NSString*) _desc
{
	char buf[4];
	if (self) {
		self.bytes = _size;
		self.height = _height;
		self.description = _desc; 
		
		for (int i = 0; i < [_name length];i++){
			buf[i] = [_name characterAtIndex:i];
		}
		name = [[NSData alloc]initWithBytes:&buf length:4];
		self.offset = -1;
		self.length = -1;
	}
	return self;
}
@end
