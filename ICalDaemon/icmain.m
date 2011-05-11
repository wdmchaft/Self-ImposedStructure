////  icmain.m//  ICalDaemon////  Created by Charles on 11/17/10.//  Copyright 2010 zer0gravitas.com. All rights reserved.//#import <Cocoa/Cocoa.h>#import <Foundation/Foundation.h>#import "ICalEventHandler.h"#import "ScriptDaemon.h"int main (int argc, const char * argv[]) {	NSLog(@"ICalDaemon in the beginning.");	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	BOOL started = [[NSUserDefaults standardUserDefaults] boolForKey:@"running"];	if (started){		NSLog(@"ICalDaemon already running.");	} else {		@try {			NSLog(@"ICalDaemon in try.");			NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];			[ud setBool:YES forKey:@"running"];			[ud synchronize];						ICalEventHandler *icHandler = [ICalEventHandler new];			ScriptDaemon *daemon = [[[ScriptDaemon alloc]initWithName:@"com.zer0gravitas.icaldaemon"]retain];			[daemon setAseHandler:icHandler];			[daemon loop:pool];		}		@catch (NSException * e) {			NSLog(@"exeption in ICalDaemon: %@", e);					}		@finally {			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"running"];			[[NSUserDefaults standardUserDefaults] synchronize];		}	}	[pool drain];    return 0;}