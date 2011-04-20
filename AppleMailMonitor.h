//
//  AppleMailMonitor.h
//  Self-Imposed Structure
//
//  Created by Charles on 4/14/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScriptingMonitor.h"

@interface AppleMailMonitor : ScriptingMonitor {
@private
    
}
+(AppleMailMonitor*) appleMailShared;
@end
