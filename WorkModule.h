//
//  WorkModule.h
//  WorkPlayAway
//
//  Created by Charles on 2/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseInstance.h"
#import "Stateful.h"
#import "ChooseApp.h"


@interface WorkModule : BaseInstance <Stateful, NSTableViewDataSource, NSTableViewDelegate> {
	NSDistributedNotificationCenter *notificationCenter;
	NSDistributedNotificationCenter *wsCenter;
	NSMutableArray *appsToWatch;
	NSTableView *tableApps;
	NSButton *buttonAdd;
	NSButton *buttonRemove;
	ChooseApp *chooseApp;
}
@property (nonatomic, retain) NSDistributedNotificationCenter *notificationCenter;
@property (nonatomic, retain) NSDistributedNotificationCenter *wsCenter;
@property (nonatomic, retain) NSMutableArray *appsToWatch;
@property (nonatomic, retain) ChooseApp *chooseApp;
@property (nonatomic, retain) IBOutlet NSTableView *tableApps;
@property (nonatomic, retain) IBOutlet NSButton *buttonAdd;
@property (nonatomic, retain) IBOutlet NSButton *buttonRemove;

- (IBAction) clickState: (id) sender;
- (IBAction) clickAdd: (id) sender;
- (IBAction) clickRemove: (id) sender;
@end
