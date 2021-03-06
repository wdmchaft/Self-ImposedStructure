//
//  BaseReporter.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reporter.h"
#import "BaseInstance.h"

#define ISWORKRELATED @"WorkRelated"
#define SUMMARYTITLE @"SummaryTitle"

@interface BaseReporter : BaseInstance <Reporter>{
	NSString *summaryTitle;
	BOOL isWorkRelated;
}
@property (nonatomic, retain) NSString *summaryTitle;
@property (nonatomic, assign) BOOL isWorkRelated;



@end
