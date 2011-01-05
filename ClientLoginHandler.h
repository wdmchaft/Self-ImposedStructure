//
//  ClientLoginHandler.h
//  Nudge
//
//  Created by Charles on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ClientLoginHandler : NSObject {
	NSObject *caller;
	NSMutableData *respBuffer;
}
@property (nonatomic,retain) NSObject *caller;
@property (nonatomic,retain) NSMutableData *respBuffer;

- (id) initWithCallback:(id) callback;
@end
