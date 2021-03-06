	//
//  ListHandler.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/4/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResponseRESTHandler.h"
#import "RTMProtocol.h"

@interface ListHandler : ResponseRESTHandler <NSXMLParserDelegate> {
	NSMutableDictionary *tempDictionary;
    NSMutableString *temp;
    NSDateFormatter *inputFormatter; 

}
@property (nonatomic,retain) NSMutableDictionary *tempDictionary;
@property (nonatomic,retain) NSMutableString *temp;
@property (nonatomic,retain) NSDateFormatter *inputFormatter;

- (id) initWithContext:(RTMProtocol*) ctx delegate: (NSObject*) del selector: (SEL) callback ;
- (void) addItem;
 @end
