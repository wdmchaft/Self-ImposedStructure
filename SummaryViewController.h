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
	<Reporter> reporter;
	NSMutableArray *data;
	NSSize size;
}

@property (nonatomic,retain) IBOutlet BGHUDTableView *table; 
@property (nonatomic,retain) IBOutlet BGHUDProgressIndicator *prog; 
@property (nonatomic,retain) <Reporter> reporter; 
@property (nonatomic,retain) NSMutableArray *data; 
@property (nonatomic ) NSSize size; 

- (id)initWithNibName:(NSString *)nibNameOrNil 
			   bundle:(NSBundle *)nibBundleOrNil 
			   module: (<Reporter>) report
				 size:(NSSize) pt ;

- (void) initTable;

- (void) refresh;

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