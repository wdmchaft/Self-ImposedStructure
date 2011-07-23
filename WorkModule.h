//
//  WorkModule.h
//  Self-Imposed Structure
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
	NSMutableDictionary *appsToWatch;
	NSTableView *tableApps;
	NSButton *buttonAdd;
	NSButton *buttonRemove;
	ChooseApp *chooseApp;
	NSString *queueName;
    NSTimeInterval fidgetFactor;
    NSTimer *fidgetTimer;
    NSTextField *fidgetField;
}
@property (nonatomic, retain) NSDistributedNotificationCenter *notificationCenter;
@property (nonatomic, retain) NSDistributedNotificationCenter *wsCenter;
@property (nonatomic, retain) NSMutableDictionary *appsToWatch;
@property (nonatomic, retain) ChooseApp *chooseApp;
@property (nonatomic, retain) NSString *queueName;
@property (nonatomic, retain) IBOutlet NSTableView *tableApps;
@property (nonatomic, retain) IBOutlet NSButton *buttonAdd;
@property (nonatomic, retain) IBOutlet NSButton *buttonRemove;
@property (nonatomic, assign) NSTimeInterval fidgetFactor;
@property (nonatomic, retain) NSTimer *fidgetTimer;
@property (nonatomic, retain) IBOutlet NSTextField *fidgetField;

- (IBAction) clickState: (id) sender;
- (IBAction) clickAdd: (id) sender;
- (IBAction) clickRemove: (id) sender;
@end
