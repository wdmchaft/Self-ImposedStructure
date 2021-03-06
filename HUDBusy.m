//
//  HUDBusy.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/4/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "HUDBusy.h"


@implementation HUDBusy

@synthesize prog, label, cancel, retry,reporter,data, caller;

- (void) awakeFromNib
{
	NSLog(@"awaking");
}
- (void) refresh: (BOOL) useCache
{
	NSLog(@"hudBusy refresh useCache: %@", useCache ? @"yes" : @"no");
	[prog setHidden:NO];
	[prog startAnimation:self];
	[reporter refresh: self isSummary:YES useCache: useCache];
}

-(void) handleError: (WPAAlert*) error
{
	[prog setHidden:YES];
	[prog stopAnimation:self];
}	

- (void) handleAlert: (WPAAlert*) alert
{
	if (alert.lastAlert){
		NSLog(@"%@ last alert for [%@] count = %d", self, [reporter name], [data count]);
		[prog setHidden:YES];
		[prog stopAnimation:self];
		if (!data){
			data = [NSMutableArray new]; // no data but we are done
		}
		[caller viewSized: [self view] reporter: reporter data:data];
		
	}
	else {
		if (!data){
			data = [NSMutableArray new];
		}
		[data addObject: alert.params];
		//	[table noteNumberOfRowsChanged];
	}
}

- (void) clickCancel: (id) sender
{
	[caller viewSized:[self view] reporter:reporter data:[NSMutableArray new]];
}

- (void) clickRetry: (id) sender
{
	[reporter refresh: self isSummary:YES useCache:NO];
}
- (void) release
{
	data = nil;
	reporter = nil;
	caller = nil;
}
@end
