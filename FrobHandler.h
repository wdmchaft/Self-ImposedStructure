//
//  FrobHandler.h
//  CocoaTest
//
//  Created by Charles on 10/30/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"
#import "RTMModule.h"


@interface FrobHandler : ResponseRESTHandler {
	
}

- (void) handleResponse: (NSData*) respStr;
@end
