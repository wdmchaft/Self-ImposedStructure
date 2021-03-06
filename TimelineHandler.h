//
//  TimelineHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/7/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"
#import "RTMProtocol.h"

@interface TimelineHandler : ResponseRESTHandler <NSXMLParserDelegate>{
	NSString *timeline;
}

@property (nonatomic, retain) NSString *timeline;
@end
