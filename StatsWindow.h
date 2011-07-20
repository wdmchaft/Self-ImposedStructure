//
//  StatsWindow.h
//  Self-Imposed Structure
//
//  Created by Charles on 12/31/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RefreshableViewController.h"

@interface LoadableMeta : NSObject
{
	NSString *identifier;
	NSString *viewName;
	Class controlClass;
	RefreshableViewController *ctrl;
}
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *viewName;
@property (nonatomic, retain) Class controlClass;
@property (nonatomic, retain) RefreshableViewController *ctrl;

- (id) initWithId: (NSString*) idStr view: (NSString*) vNname controller: (Class) cClass;
@end

@interface StatsWindow : NSWindowController <NSTabViewDelegate> {
	NSTabView *tabView;
	NSDictionary *tabViewsTable;
}

@property (nonatomic,retain) IBOutlet NSTabView *tabView;
@property (nonatomic,retain) NSDictionary *tabViewsTable;


@end
