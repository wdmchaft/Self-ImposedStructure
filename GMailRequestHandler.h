//
//  GMailRequestHandler.h
//  WorkPlayAway
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RulesTableData.h"
#import "Note.h"
#import "AlertHandler.h"
#import "BaseInstance.h"

@interface GMailRequestHandler : NSObject <NSXMLParserDelegate>{

	NSMutableData *respBuffer;

	NSMutableDictionary *msgDict;
	NSString *titleStr;
	NSString *summaryStr;
	NSString *idStr;
	NSString *nameStr;
	NSString *emailStr;
	NSString *bufferStr;
	NSNumber *highestTagValue;
	NSNumber *minTagValue;
	NSDate *issuedDate;
	NSDate *modifiedDate;
	NSString *hrefStr;
	NSArray *rules;
	<AlertHandler> alertHandler;
	NSObject *validationHandler;
	NSObject *callback;
	NSDateFormatter *timeStampFormatter;
}

@property (nonatomic,retain) NSMutableData *respBuffer;
@property (nonatomic,retain) NSMutableDictionary *msgDict;
@property (nonatomic,retain) NSString *emailStr;
@property (nonatomic,retain) NSString *titleStr;
@property (nonatomic,retain) NSString *idStr;
@property (nonatomic,retain) NSString *nameStr;
@property (nonatomic,retain) NSString *hrefStr;
@property (nonatomic,retain) NSString *summaryStr;
@property (nonatomic,retain) NSDate *issuedDate;
@property (nonatomic,retain) NSDate *modifiedDate;
@property (nonatomic,retain) NSString *bufferStr;
@property (nonatomic, retain) NSNumber *highestTagValue;
@property (nonatomic, retain) NSNumber *minTagValue;
@property (nonatomic, retain) NSArray* rules;

@property (nonatomic, retain) <AlertHandler> alertHandler;
@property (nonatomic, retain) NSObject* validationHandler;
@property (nonatomic, retain) NSObject* callback;
@property (nonatomic, retain) NSDateFormatter *timeStampFormatter;

-(NSNumber*) getIdTagValue: (NSString*) tag;
- (void) addEntry: (NSMutableDictionary*) msgDict;
-(id) initWithTagValue: (NSNumber*) tagValue
				 rules: (NSArray*) inRules 
			   handler: (<AlertHandler>) handler
			  delegate: (NSObject*) delegate;
-(id) initForValidation: (NSObject*) handler;
- (NSDate*) dateFromTimeStamp:(NSString*) stamp;
@end
