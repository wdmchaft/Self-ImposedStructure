//
//  FilterRule.m
//  Nudge
//
//  Created by Charles on 1/2/11.
//  Copyright 2011 workplayaway.com. All rights reserved.
//

#import "FilterRule.h"


@implementation FilterRule
@synthesize ruleType;
@synthesize compareType; 
@synthesize predicate;
@synthesize fieldType;

- (id) initFromString: (NSString*) str
{
	if (self)
	{
		NSArray *array = [str componentsSeparatedByString:@"_"];
		NSString *val1 = [array objectAtIndex:0];
		NSString *val2 = [array objectAtIndex:1];
		NSString *val3 = [array objectAtIndex:2];
		NSString *val4 = [array objectAtIndex:3];
		self.ruleType = [val1 intValue];
		self.fieldType = [val2 intValue];
		self.compareType = [val3 intValue];
		self.predicate = val4;
	}
	return self;
}

+ (FilterResult) processFilters: (NSArray*) filters forMessage: (NSDictionary*) msgAttrs
{
	for (FilterRule *rule in filters){
		if ([rule match:msgAttrs]){
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
		default:
			break;
	}
	NSRange range;
	switch (compareType) {
		case COMPARE_EQUALTO:
			return [compAttr isEqualToString:predicate];
			break;
		case COMPARE_STARTSWITH:
			return [compAttr hasPrefix:predicate];
			break;
		case COMPARE_CONTAINS:
			range = [compAttr rangeOfString:predicate];
			return range.location >= 0;
			break;

		default:
			break;
	}
	return NO;
}
@end
