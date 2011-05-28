//
//  ActivityComboData.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SwitchActivityDialog.h"

@interface ActivityComboData : NSObject <NSComboBoxDataSource> {
	SwitchActivityDialog *dialog;
}

@property (nonatomic,retain) IBOutlet SwitchActivityDialog *dialog;
@end
