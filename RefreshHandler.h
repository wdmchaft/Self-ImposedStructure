//
//  RefreshHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ListHandler.h"
#import "RTMModule.h"

@interface RefreshHandler : ListHandler <NSXMLParserDelegate> {
}
- (RefreshHandler*) initWithContext: (RTMModule*) ctx andDelegate: (id<RTMCallback>) delegate;
@end
