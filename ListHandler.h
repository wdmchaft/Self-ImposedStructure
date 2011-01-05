	//
//  ListHandler.h
//  RTGTest
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"
#import "RTMModule.h"

@interface ListHandler : ResponseRESTHandler <NSXMLParserDelegate> {
}
- (ListHandler*) initWithContext: (RTMModule*) ctx andDelegate: (<RTMCallback>) delegate;
- (void) addItem;
 @end
