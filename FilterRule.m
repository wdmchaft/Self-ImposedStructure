//
//  FilterRule.m
//  Nudge
//
//  Created by Charles on 1/2/11.
//  Copyright 2011 zer0gravitas.com. All rights reserved.
//

#import "FilterRule.h"


@implementation FilterRule
@synthesize ruleType;
@synthesize compareType; 
@synthesize predicate;
@synthesize fieldType;
@synthesize color;

- (id) init
{
	if (self)
	{
        color = [NSColor whiteColor];
        predicate = @"";
        
	}
	return self;
}

+ (NSArray*) loadFiltersWithTypes: (NSArray*) aryTypes
                           fields: (NSArray*) aryFields
                         compares: (NSArray*) aryCompares
                       predicates: (NSArray*) aryPredicates
                           colors: (NSArray*) aryColors
{
    NSMutableArray* temp = [NSMutableArray arrayWithCapacity:[aryFields count]];
    for (int i = 0; i < [aryFields count];i++){
        FilterRule *rule = [FilterRule new];
        
        FieldType fld = ((NSNumber*)[aryFields objectAtIndex:i]).intValue;
        RuleType typ = ((NSNumber*)[aryTypes objectAtIndex:i]).intValue;
        CompareType cmp = ((NSNumber*)[aryCompares objectAtIndex:i]).intValue;
        NSColor  *color = (NSColor*)[aryColors objectAtIndex:i];
        NSString  *pred = (NSString*)[aryPredicates objectAtIndex:i];
        [rule setFieldType:fld];
        [rule setColor:color];
        [rule setCompareType:cmp];
        [rule setPredicate:pred];
        [rule setRuleType:typ];
        [temp addObject:rule];
    }
    return [NSArray arrayWithArray:temp];
}

+ (FilterResult) processFilters: (NSArray*) filters 
                     forMessage: (NSDictionary*) msgAttrs 
                          color: (NSColor**) clr 
{
	for (FilterRule *rule in filters){
		if ([rule match:msgAttrs]){
            *clr = rule.color;
			return [FilterRule resultForRuleType: rule.ruleType];
		}
	}
	return RESULT_NONE;
}
	
+ (FilterResult) resultForRuleType: (RuleType) type
{
	switch (type) {
		case RULE_IGNORE:
			return RESULT_IGNORE;
			break;
		case RULE_SUMMARY:
            return RESULT_SUMMARYONLY;
            break;
		case RULE_IMPORTANT:
			return RESULT_IMPORTANT;
		default:
			break;
	}
	return RESULT_NONE;
}

- (BOOL) match: (NSDictionary*) msgAttrs
{
	NSString *compAttr;
	switch (fieldType) {
		case FIELD_SUBJECT:
			compAttr = [msgAttrs objectForKey:@"subject"];
			break;
		case FIELD_SUMMARY:
			compAttr = [msgAttrs objectForKey:@"summary"];
			break;
		case FIELD_NAME:
			compAttr = [msgAttrs objectForKey:@"name"];
			break;
		case FIELD_EMAIL:
			compAttr = [msgAttrs objectForKey:@"email"];
			break;
		case FIELD_READSTATUS:
			compAttr = [msgAttrs objectForKey:@"readStatus"];
			break;		
        default:
			break;
	}
	NSRange range;
	switch (compareType) {
		case COMPARE_EQUALTO:
            if (fieldType == FIELD_READSTATUS){
                BOOL predBool = ((NSNumber*)predicate).boolValue;
                BOOL compBool = ((NSNumber*)compAttr).boolValue;
                return (predBool == compBool);
            }
			return [compAttr isEqualToString:predicate];
			break;
		case COMPARE_STARTSWITH:
            NSLog(@"predicate = %@", predicate);
			return [compAttr hasPrefix:predicate];
			break;
		case COMPARE_CONTAINS:
			range = [compAttr rangeOfString:predicate];
			return range.length == [predicate length];
			break;

		default:
			break;
	}
	return NO;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"pred (%@)= %@", [[predicate class ] description ], predicate];
}
@end
