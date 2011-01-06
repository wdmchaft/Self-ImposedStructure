//
//  TimelineHandler.h
//  RTGTest
//
//  Created by Charles on 11/7/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"

@interface TimelineHandler : ResponseRESTHandler <NSXMLParserDelegate>{
	NSMutableString *timeLine;	
}

@property (nonatomic, retain) NSMutableString *timeLine;
- (TimelineHandler*) initWithHandler:(<RTMCallback>) delegate;

@end
