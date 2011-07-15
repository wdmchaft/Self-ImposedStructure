//
//  ActivityComboData.h
//  Self-Imposed Structure
//
//  Created by Charles on 5/2/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskList.h"

@interface ActivityComboData : NSObject <NSComboBoxDataSource> {
	id<TaskList> list;
}

@property (nonatomic, retain) IBOutlet id<TaskList> list;
@end
