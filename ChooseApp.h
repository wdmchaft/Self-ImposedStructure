//
//  ChooseApp.h
//  Self-Imposed Structure
//
//  Created by Charles on 2/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ChooseApp : NSWindowController <NSComboBoxDataSource> {
	NSComboBox *cbRunningApps;
	NSButton *buttonOk;
	NSButton *buttonCancel;
	NSArray *allApps;
	NSRunningApplication *chosenApp;
    NSMutableDictionary *appsDict;
    NSArray *appNames;
}
@property (nonatomic,retain) IBOutlet NSComboBox *cbRunningApps;
@property (nonatomic,retain) IBOutlet NSButton *buttonOk;
@property (nonatomic,retain) IBOutlet NSButton *buttonCancel;
@property (nonatomic, retain) NSArray *allApps;
@property (nonatomic, retain) NSRunningApplication *chosenApp;
@property (nonatomic, retain) NSMutableDictionary *appsDict;
@property (nonatomic, retain) NSArray *appNames;

- (IBAction) clickOk: (id) sender;
- (IBAction) clickCancel: (id) sender;
@end
