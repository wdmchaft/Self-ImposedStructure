//
//  Callback.h
//  RTGTest
//
//  Created by Charles on 11/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//
// Used by various response handlers to return control -- makes the compiler stop yapping at me. 
//
@protocol RTMCallback  <NSObject>

-(void) frobDone;
-(void) tokenDone;
-(void) refreshDone;
-(void) listsDone;
-(void) listDone;
-(void) timelineDone;
-(void) rmDone;

@end
