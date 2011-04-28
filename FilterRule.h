//
//  FilterRule.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/2/11.
//  Copyright 2011 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define RULE_IMPORTANT_STR @"Important"
#define RULE_IGNORE_STR @"Ignore"
#define RULE_NORMAL_STR @"Normal"
#define RULE_SUMMARY_STR @"Summary Only"

typedef enum {
	RULE_IMPORTANT,
    RULE_SUMMARY,
    RULE_NORMAL,
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
#define FIELD_READSTATUS_STR @"Read"

typedef enum {
	FIELD_SUMMARY,
	FIELD_NAME,
	FIELD_SUBJECT,
	FIELD_EMAIL,
    FIELD_READSTATUS
} FieldType;

typedef enum {
	RESULT_IMPORTANT,
	RESULT_SUMMARYONLY,
    RESULT_IGNORE,
	RESULT_NONE,
} FilterResult;

@interface FilterRule : NSWindowController {
	RuleType ruleType;
	FieldType fieldType;
	CompareType compareType;
	id predicate;
	NSColor *color;
}
@property (nonatomic) RuleType ruleType;
@property (nonatomic) FieldType fieldType;
@property (nonatomic) CompareType compareType;
@property (nonatomic, retain) id predicate;
@property (nonatomic, retain) NSColor* color;

+ (FilterResult) resultForRuleType: (RuleType) type;
+ (FilterResult) processFilters: (NSArray*) filters 
                     forMessage: (NSDictionary*) msgAttrs 
                          color: (NSColor**) clr;
- (BOOL) match: (NSDictionary*) msgAttrs;
+ (NSArray*) loadFiltersWithTypes: (NSArray*) aryTypes
                           fields: (NSArray*) aryfields
                         compares: (NSArray*) aryCompares
                       predicates: (NSArray*) aryPredicates
                           colors: (NSArray*) aryColors;
@end
