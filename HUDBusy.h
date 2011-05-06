//
//  HUDBusy.h
//  WorkPlayAway
//
//  Created by Charles on 5/4/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SummaryHUDCallback.h"
#import "Reporter.h"
#import "AlertHandler.h"

@interface HUDBusy : NSViewController <AlertHandler> {
	NSProgressIndicator *prog;
	NSTextField			*label;
	NSButton			*cancel;
	NSButton			*retry;
	id<Reporter> reporter;
	NSMutableArray *data;
	id<SummaryHUDCallback> caller;

}
@property (nonatomic, retain) IBOutlet NSProgressIndicator *prog;
@property (nonatomic, retain) IBOutlet NSTextField			*label;
@property (nonatomic, retain) IBOutlet NSButton			*cancel;
@property (nonatomic, retain) IBOutlet NSButton			*retry;
@property (nonatomic,retain)id<SummaryHUDCallback> caller; 
@property (nonatomic,retain) NSMutableArray *data; 
@property (nonatomic,retain) id<Reporter> reporter; 

- (void) refresh;
- (IBAction) clickRetry: (id) sender;
- (IBAction) clickCancel: (id) sender;
@end
