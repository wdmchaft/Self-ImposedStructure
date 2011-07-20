//
//  TodosViewController.h
//  WorkPlayAway
//
//  Created by Charles on 7/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RefreshableViewController.h"

@interface TodosViewController : RefreshableViewController {
	NSTableView *tasksTable;
	NSProgressIndicator *prog;
	NSArrayController *data;
}
@property (nonatomic,retain) IBOutlet NSTableView *tasksTable;
@property (nonatomic,retain) IBOutlet NSProgressIndicator *prog;
@property (nonatomic,retain) IBOutlet NSArrayController *data;
@end
