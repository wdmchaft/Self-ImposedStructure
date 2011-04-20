//
//  TimelineHandler.h
//  selfstruct
//
//  Created by Charles on 11/7/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"

@interface TimelineHandler : ResponseRESTHandler <NSXMLParserDelegate>{
	NSMutableString *timeLine;	
}

@property (nonatomic, retain) NSMutableString *timeLine;
- (TimelineHandler*) initWithHandler:(id<RTMCallback>) delegate;

@end
