//
//  Callback.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/5/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
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
-(void) taskRefreshDone;
-(void) handleComplete;
@end
