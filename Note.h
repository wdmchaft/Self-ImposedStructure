//
//  Alert.h
//  Nudge
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Note : NSObject {
	NSString* moduleName;
	BOOL urgent;
	NSString *title;
	NSString *message;
	NSDictionary *params;
	BOOL sticky;
}
@property (nonatomic, retain) NSString* moduleName;
@property (nonatomic)BOOL urgent;
@property (nonatomic)BOOL sticky;
@property (nonatomic ,retain)NSString *title;
@property (nonatomic ,retain)NSString *message;
@property (nonatomic ,retain)NSDictionary *params;

@end
