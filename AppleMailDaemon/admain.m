////  ammain.m//  AppleMailManager////  Created by Charles on 11/17/10.//  Copyright 2010 zer0gravitas.com. All rights reserved.//#import <Cocoa/Cocoa.h>#import <Foundation/Foundation.h>#import "MailEventHandler.h"#import "ScriptDaemon.h"int main (int argc, const char * argv[]) {    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	BOOL started = [[NSUserDefaults standardUserDefaults] boolForKey:@"running"];	if (started){		NSLog(@"AppleMailDaemon already running.");	} else {		@try {			NSLog(@"AppleMailDaemon in try.");			NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];			[ud setBool:YES forKey:@"running"];			[ud synchronize];						MailEventHandler *amHandler = [MailEventHandler new];			ScriptDaemon *daemon = [[ScriptDaemon alloc]initWithName:@"com.zer0gravitas.applemaildaemon"];			[daemon setAseHandler:amHandler];			[daemon loop:pool];					}		@catch (NSException * e) {			//		}		@finally {			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"running"];			[[NSUserDefaults standardUserDefaults] synchronize];	}	}	[pool drain];    return 0;}