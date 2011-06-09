//
//  CompleteHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/9/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"
#import "RTMProtocol.h"

@interface CompleteRespHandler : ResponseRESTHandler <NSXMLParserDelegate>{
	RouteInfo *route;
}
@property (nonatomic, retain) RouteInfo* route;
- (id) initWithContext:(RTMProtocol*) ctx 
			  delegate: (NSObject*) tgt 
			  selector: (SEL) cb  
				 route: (RouteInfo*) info;
@end
