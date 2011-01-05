//
//  IconData.h
//  Nudge
//
//  Created by Charles on 12/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum _IconSize{
	SZ_16,
	SZ_32,
	SZ_48,
	SZ_128,
	SZ_256
};

@interface IconData : NSObject
{
	NSData *name;
	NSNumber *bytes;
	NSNumber *height;
	NSString *description;
	int offset;
	int length;
}

@property (nonatomic, retain) NSData *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSNumber *bytes;
@property (nonatomic, retain) NSNumber *height;
@property (nonatomic)  int offset;
@property (nonatomic)  int length;
-(id)initWithName:(NSString*)name size: (NSNumber*) size height: (NSNumber*) height description: (NSString*) desc;
@end