//
//  SummaryViewController.h
//  WorkPlayAway
//
//  Created by Charles on 2/19/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
#import <BGHUDAppKit/BGHUDAppKit.h>
#import "SummaryHUDCallback.h"
#import "SVRefHandler.h"


@interface SummaryViewController : NSViewController <NSTableViewDataSource, AlertHandler, SVRefCtrl> {
	NSTableView *table;
	NSProgressIndicator *prog;
	id<Reporter> reporter;
	NSMutableArray *data;
	NSFont *boldFont;
	int actualLines;
	int maxLines; 
	int width;
	id<SummaryHUDCallback> caller;
    SVRefHandler *refreshHandler;
}

@property (nonatomic,retain) IBOutlet NSTableView *table; 
@property (nonatomic,retain) SVRefHandler *refreshHandler; 
@property (nonatomic,retain) IBOutlet NSProgressIndicator *prog; 
@property (nonatomic,retain) id<Reporter> reporter; 
@property (nonatomic,retain) NSMutableArray *data; 
@property (nonatomic,retain) NSFont *boldFont; 
@property (nonatomic,retain)id<SummaryHUDCallback> caller; 
@property (nonatomic) int actualLines; 
@property (nonatomic) int maxLines;
@property (nonatomic) int width;

- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
			   module: (id<Reporter>) report 
				 rows: (int) maxRows
             waitRows: (int) waitRows
				width:(int) width
			   caller: (id<SummaryHUDCallback>) callback ;

- (void) initTable;

- (void) refresh;
- (void) handleDouble:(id)sender;
- (int) actualHeight;

@end

@interface SummaryEventViewController : SummaryViewController {
}
@end

@interface SummaryTaskViewController : SummaryViewController {
    BOOL inRefresh;
}
@property (nonatomic) BOOL inRefresh;
@end

@interface SummaryMailViewController : SummaryViewController <NSOutlineViewDelegate, NSOutlineViewDataSource> 
{
}
@end