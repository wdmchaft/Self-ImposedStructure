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

@interface SummaryViewController : NSViewController <NSTableViewDataSource, AlertHandler> {
	BGHUDTableView *table;
	BGHUDProgressIndicator *prog;
	id<Reporter> reporter;
	NSMutableArray *data;
	NSSize size;
	NSFont *boldFont;
	int actualLines;
	int maxLines;
	NSObject *caller;
}

@property (nonatomic,retain) IBOutlet BGHUDTableView *table; 
@property (nonatomic,retain) IBOutlet BGHUDProgressIndicator *prog; 
@property (nonatomic,retain) id<Reporter> reporter; 
@property (nonatomic,retain) NSMutableArray *data; 
@property (nonatomic,retain) NSFont *boldFont; 
@property (nonatomic,retain) NSObject *caller; 
@property (nonatomic) NSSize size; 
@property (nonatomic) int actualLines; 
@property (nonatomic) int maxLines;

- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
			   module: (id<Reporter>) report 
				 rows: (int) maxRows
				width:(int) width
			   caller: (NSObject*) callback ;

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