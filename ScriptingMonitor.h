//
//  ScriptingMonitor.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScriptingMonitor : NSObject {
@private
    BOOL stopMe;
    NSAppleEventDescriptor *eventRes;
    NSDictionary *errorRes;
    NSMutableArray *scriptQueue;
    NSMutableArray *callbackQueue;
	NSDate* lastStart;
	NSThread* scriptThread;	
    NSString* prefix;
}

@property (nonatomic) BOOL stopMe;
@property (nonatomic,retain) NSAppleEventDescriptor *eventRes;
@property (nonatomic,retain) NSDictionary *errorRes;
@property (nonatomic,retain) NSMutableArray *scriptQueue;
@property (nonatomic,retain) NSMutableArray *callbackQueue;
@property (nonatomic,retain) NSDate *lastStart;
@property (nonatomic,retain) NSThread *scriptThread;
@property (nonatomic,retain) NSString *prefix;

- (void) sendScript: (NSString*) script withCallback: (NSString*) callback;
- (void) sendDone;
- (void) startLoop;
- (void) reset;
@end

