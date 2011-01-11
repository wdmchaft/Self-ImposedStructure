	//
//  ListHandler.h
//  RTGTest
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"
#import "RTMModule.h"

@interface ListHandler : ResponseRESTHandler <NSXMLParserDelegate> {
	NSMutableDictionary *tempDictionary;
	NSMutableArray *tempList;
}
@property (nonatomic,retain) NSMutableDictionary *tempDictionary;
@property (nonatomic,retain) NSMutableArray *tempList;
- (ListHandler*) initWithContext: (RTMModule*) ctx andDelegate: (<RTMCallback>) delegate;
- (void) addItem;
 @end
