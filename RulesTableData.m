//
//  RulesTableData.m
//  Nudge
//
//  Created by Charles on 1/3/11.
//  Copyright 2011 workplayaway.com. All rights reserved.
//

#import "RulesTableData.h"


@implementation RulesTableData
@synthesize allRules;
@synthesize predCol,boolCell;

- (id) initWithRules: (NSMutableArray*) data
{
	if (self)
	{
		allRules = data;
	}
	return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [allRules count];
}

- (id) objValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [allRules count]);
    FilterRule *rule  = [allRules objectAtIndex:row];
	NSString *colName = (NSString*) [tableColumn identifier];
	if ([colName isEqualToString:TYPE_COL]){
		theValue = [NSNumber numberWithInt:rule.ruleType];
	}
	if ([colName isEqualToString:FIELD_COL]){
		theValue = [NSNumber numberWithInt:rule.fieldType];
	}
	if ([colName isEqualToString:COMPARE_COL]){
		theValue = [NSNumber numberWithInt:rule.compareType];
	}
	if ([colName isEqualToString:VALUE_COL]){
		theValue = rule.predicate;
	}
    if ([colName isEqualToString:COLOR_COL]){
		theValue = rule.color;
	}
    return theValue;
}


- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [allRules count]);
    FilterRule *rule  = [allRules objectAtIndex:row];
	NSString *colName = (NSString*) [tableColumn identifier];
	if ([colName isEqualToString:TYPE_COL]){
		theValue = [NSNumber numberWithInt:rule.ruleType];
	}
	if ([colName isEqualToString:FIELD_COL]){
		theValue = [NSNumber numberWithInt:rule.fieldType];
	}
	if ([colName isEqualToString:COMPARE_COL]){
		theValue = [NSNumber numberWithInt:rule.compareType];
	}
	if ([colName isEqualToString:VALUE_COL]){
		theValue = rule.predicate;
	}
    if ([colName isEqualToString:COLOR_COL]){
		theValue = rule.color;
	}
    return theValue;	
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(NSInteger)rowIndex
{	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [allRules count]);
    FilterRule *rule = [allRules objectAtIndex:rowIndex];
 //   [rule setObject:anObject forKey:[aTableColumn identifier]];
	NSString *colName = (NSString*) [aTableColumn identifier];
	if ([colName isEqualToString:TYPE_COL]){
		rule.ruleType = [anObject intValue];
	}
	if ([colName isEqualToString:FIELD_COL]){
		rule.fieldType = [anObject intValue];
	}
	if ([colName isEqualToString:COMPARE_COL]){
		rule.compareType = [anObject intValue];
	}
	if ([colName isEqualToString:VALUE_COL]){
		rule.predicate = anObject;
	}
	if ([colName isEqualToString:COLOR_COL]){
		rule.color = anObject;
	}
    return;
}
@end
