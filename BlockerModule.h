//
//  BlockerModule.h
//  WorkPlayAway
//
//  Created by Charles on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseModule.h"
#define BLOCKERFILE @"hostsblocker"
#define BACKUPFILE @"hostsbackup.txt"
#define DOMAIN_COL @"Domain"
#define SWITCHER @"Switcher"
#define TXT @"txt"

@interface BlockerModule : BaseModule <NSTableViewDataSource> {
	NSMutableArray *blackList;
	NSTableView *listBrowser;
	NSButton *addButton;
	NSButton *removeButton;
}

@property (nonatomic, retain) NSMutableArray *blackList;
@property (nonatomic, retain) IBOutlet NSTableView *listBrowser;
@property (nonatomic, retain) IBOutlet NSButton *addButton;
@property (nonatomic, retain) IBOutlet NSButton *removeButton;

- (void)addClicked: (id) sender;
- (void)removeClicked: (id) sender;
- (void) block;
- (void) unblock;
@end
