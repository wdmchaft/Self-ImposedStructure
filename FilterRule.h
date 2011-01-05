//
//  FilterRule.h
//  Nudge
//
//  Created by Charles on 1/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define RULE_IMPORTANT_STR @"Important"
#define RULE_IGNORE_STR @"Ignore"

typedef enum {
	RULE_IMPORTANT,
	RULE_IGNORE
} RuleType;

#define COMPARE_EQUALTO_STR  @"Equals"
#define COMPARE_STARTSWITH_STR @"Starts With"
#define COMPARE_CONTAINS_STR @"Contains"

typedef enum {
	COMPARE_EQUALTO,
	COMPARE_STARTSWITH,
	COMPARE_CONTAINS
} CompareType;

#define FIELD_SUMMARY_STR @"Summary"
#define FIELD_NAME_STR @"Field"
#define FIELD_SUBJECT_STR @"Subject"
#define FIELD_EMAIL_STR @"Email"

typedef enum {
	FIELD_SUMMARY,
	FIELD_NAME,
	FIELD_SUBJECT,
	FIELD_EMAIL
} FieldType;

typedef enum {
	RESULT_IMPORTANT,
	RESULT_IGNORE,
	RESULT_NONE
} FilterResult;

@interface FilterRule : NSWindowController {
	RuleType ruleType;
	FieldType fieldType;
	CompareType compareType;
	NSString *predicate;
}
@property (nonatomic) RuleType ruleType;
@property (nonatomic) FieldType fieldType;
@property (nonatomic) CompareType compareType;
@property (nonatomic, retain) NSString* predicate;

+ (FilterResult) resultForRuleType: (RuleType) type;
+ (FilterResult) processFilters: (NSArray*) filters forMessage: (NSDictionary*) msgAttrs;
- (id) initFromString: (NSString*) str;
- (BOOL) match: (NSDictionary*) msgAttrs;

@end
