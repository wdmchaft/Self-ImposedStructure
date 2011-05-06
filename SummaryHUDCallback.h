//
//  SummaryHUDCallback.h
//  Self-Imposed Structure
//
//  Created by Charles on 3/15/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reporter.h"

@protocol SummaryHUDCallback <NSObject>
- (void) viewSized: (NSView*) view reporter: (id<Reporter>) rpt data: (NSArray*) array; 
@end
