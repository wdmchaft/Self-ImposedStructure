//
//  HostsFileSwitcher.m 
//  WorkPlayAway
//
//  Created by Charles on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HostsFileSwitcher.h"
#import <Foundation/Foundation.h>
#include "stdio.h"

#define HOSTSBASE1 @"##\n# Host Database\n#\n# localhost is used to configure the loopback interface\n# when the system is booting.  Do not change this entry."
#define HOSTSBASE2 @"\n##\n127.0.0.1	localhost\n255.255.255.255	broadcasthost\n::1             localhost\nfe80::1%lo0	localhost\n"


//
// This executable must run as root -- it will be installed by root and must have the sticky bit set so that it can
// modify /etc/hosts.  But to be safe, this tool will take as input a text file containing domain names and will
// write out a new hosts file setting each domain name to map to localhost (127.0.0.1)
// The ONLY thing this can do is block domains -- it can not remap domains in any other way.
//
//
@implementation HostsFileSwitcher

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *args = [[NSProcessInfo processInfo] arguments];
	if ([args count] == 0){
		return 1;
	}

	NSError *errInfo = nil;
	if ([args count] > 2){
		printf("got backup file\n");
		NSString *backupFilePath = [args objectAtIndex:2];
		NSString *hostsOrig = [NSString stringWithContentsOfFile:@"/etc/hosts"
														encoding:NSUTF8StringEncoding
														   error: &errInfo];
		if (errInfo){
			fprintf(stderr, "%s", [errInfo.localizedFailureReason cStringUsingEncoding:NSUTF8StringEncoding]);
			return 1;
		}
		[hostsOrig writeToFile:backupFilePath atomically:YES encoding:NSUTF8StringEncoding error: &errInfo];
		if (errInfo){
			fprintf(stderr , "%s", [errInfo.localizedFailureReason cStringUsingEncoding:NSUTF8StringEncoding]);
			return 2;
		}
	}
	NSArray *allDomains = [[NSArray alloc]initWithObjects:@"", nil ];
	if ([args count] > 1){
		NSString *replaceFilePath = [args objectAtIndex:1];
		NSString *hostsNew = [NSString stringWithContentsOfFile:replaceFilePath 
													   encoding:NSUTF8StringEncoding 
														  error:&errInfo];
	
		allDomains = [hostsNew componentsSeparatedByString:@"\n"];
	}
	NSString *blockedDomains = [NSString new];
	blockedDomains = [blockedDomains stringByAppendingString:HOSTSBASE1];
	blockedDomains = [blockedDomains stringByAppendingString:HOSTSBASE2];
	for (NSString *domain in allDomains){
		
		if ([domain	length] > 0){
			printf("%s\n",[domain cStringUsingEncoding:NSUTF8StringEncoding]);
			blockedDomains = [blockedDomains stringByAppendingFormat:@"127.0.0.1\t%@\n",domain ];
		}
	}
	[blockedDomains writeToFile:@"/etc/hosts" atomically:YES encoding:NSUTF8StringEncoding error: &errInfo];
	if (errInfo){
		fprintf(stderr, "%s", [errInfo.localizedFailureReason cStringUsingEncoding:NSUTF8StringEncoding]);
		return 3;
	}
    
	[pool release];
    return 0;
}
@end
