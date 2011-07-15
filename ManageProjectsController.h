//
//  ManageProjectsController.h
//  WorkPlayAway
//
//  Created by Charles on 7/11/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddProjectController : NSWindowController {
	NSTextField *name;
	NSTextField *notes;
}
@property (nonatomic, retain) IBOutlet NSTextField *name;
@property (nonatomic, retain) IBOutlet NSTextField *notes;
- (IBAction) clickOk: (id) sender;
- (IBAction) clickCancel: (id) sender;
@end

@interface ManageProjectsController : NSWindowController {
	NSTableView *projectsTable;
	NSButtonCell *addCell;
	NSButtonCell *removeCell;
	NSArrayController *projList;
}
@property (nonatomic, retain) IBOutlet NSTableView *projectsTable;
@property (nonatomic, retain) IBOutlet NSButtonCell *addCell;
@property (nonatomic, retain) IBOutlet NSButtonCell *removeCell;
@property (nonatomic, retain) IBOutlet NSArrayController *projList;
- (IBAction) clickAdd: (id) sender;
- (IBAction) clickRetire: (id) sender;

@end
