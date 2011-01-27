//
//  ModulesData.m
//  Nudge
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "ModulesTableData.h"
#include "Module.h"
#include "Columns.h"
#import "Context.h"

@implementation ModulesTableData
@synthesize instances ;

- (ModulesTableData*) initWithDictionary: (NSMutableDictionary*) data
{
	if (self)
	{
		instances = data;
	}
	return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [instances count];
}
- (id) objValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
	NSArray *modList = [instances allValues];
    NSParameterAssert(row >= 0 && row < [modList count]);
    <Instance> module  = [modList objectAtIndex:row];
	NSString *colName = (NSString*) [tableColumn identifier];
	if ([colName isEqualToString:DESC_COL]){
		theValue = module.description;
	}
	if ([colName isEqualToString:SOURCE_COL]){
		theValue = [[Context sharedContext] descriptionForModule:module];
	}
	if ([colName isEqualToString:ENABLED_COL]){
		theValue = (module.enabled == YES) ? [NSNumber numberWithInt:YES] : [NSNumber numberWithInt:NO];
	}
    return theValue;
}


- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [self objValueForTableColumn: tableColumn row: row];

}

@end
