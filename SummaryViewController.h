//
//  SummaryViewController.h
//  WorkPlayAway
//
//  Created by Charles on 2/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
#import <BGHUDAppKit/BGHUDAppKit.h>
#import "SummaryHUDCallback.h"

@interface SummaryViewController : NSViewController <NSTableViewDataSource, AlertHandler> {
	BGHUDTableView *table;
	NSProgressIndicator *prog;
	id<Reporter> reporter;
	NSMutableArray *data;
	NSFont *boldFont;
	int actualLines;
	int maxLines; 
	int width;
	id<SummaryHUDCallback> caller;
}

@property (nonatomic,retain) IBOutlet BGHUDTableView *table; 
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
- (void) handleAction:(id)sender;
- (int) actualHeight;

@end

@interface SummaryEventViewController : SummaryViewController {
}
@end

@interface SummaryTaskViewController : SummaryViewController {
}
@end

@interface SummaryDeadlineViewController : SummaryViewController {
}
@end

@interface SummaryMailViewController : SummaryViewController {
}
@end