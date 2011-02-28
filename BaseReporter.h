//
//  BaseReporter.h
//  WorkPlayAway
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
#import "BaseInstance.h"


@interface BaseReporter : BaseInstance <Reporter>{
	NSString *summaryTitle;
}
@property (nonatomic,retain) NSString *summaryTitle;
@end
