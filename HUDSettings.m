//
//  HUDSettings.m
//  WorkPlayAway
//
//  Created by Charles on 3/1/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "HUDSettings.h"
#import "Reporter.h"
#import "Context.h"
@implementation HUDSetting
@synthesize reporter;
@synthesize height;
@synthesize enabled;
@synthesize label;


- (id) initWithReporter:(id<Reporter>) rpt height: (NSNumber*) hgt enabled: (NSNumber*) on label: (NSString*) lbl
{
	if (self)
	{
		reporter = rpt;
		height = hgt.intValue;
		enabled = on.boolValue;
		label = lbl;
	}
	return self;
}
@end


@implementation HUDSettings
@synthesize lines;
@synthesize enables;
@synthesize labels;
@synthesize instances;


- (id) init
{
	if (self)
	{
		instances = [NSMutableArray new];
		labels =	[NSMutableArray new];
		enables =	[NSMutableArray new];
		lines =	[NSMutableArray new];
	}
	return self;
}
- (NSUInteger) count
{
	return [instances count];
}

-(void) addInstance: (id<Reporter>) inst 
{
	[instances addObject: inst ];
	[lines addObject: [NSNumber numberWithInt:3]];
	[enables addObject:[NSNumber numberWithBool:YES]];
	[labels addObject:inst.summaryTitle];
}

-(void) addInstance: (id<Reporter>) inst 
			 height: (int) hgt
			  label: (NSString*) lbl
			enabled: (BOOL) on
{
	[instances addObject: inst ];
	[lines addObject: [NSNumber numberWithInt:hgt]];
	[enables addObject:[NSNumber numberWithBool:on]];
	[labels addObject:lbl];
}

-(void) addInstance: (id<Reporter>) inst 
			 height: (int) hgt
			  label: (NSString*) lbl
			enabled: (BOOL) on
			  index: (int) idx
{
	[instances insertObject: inst  atIndex:idx];
	[lines insertObject: [NSNumber numberWithInt:hgt] atIndex:idx];
	[enables insertObject:[NSNumber numberWithBool:on] atIndex:idx];
	[labels insertObject:[lbl copy] atIndex:idx];
}

- (HUDSetting*) settingAtIndex: (int) index
{
	HUDSetting* ret = [[HUDSetting alloc] initWithReporter:[instances objectAtIndex:index]
													height:[lines objectAtIndex:index]
												   enabled:[enables objectAtIndex:index]
													 label:[labels objectAtIndex:index]];
	return ret;
}

- (NSArray*) allEnabled
{
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[self count]];
	for (int i = 0; i < [self count];i++){
		HUDSetting *s = [self settingAtIndex:i];
		if (s.enabled)
			[ret addObject:s];
	}
	return ret;
}

-(void) removeInstance: (id<Reporter>) inst 
{
	int idx = [instances indexOfObject:inst];
	[instances removeObjectAtIndex:idx];
	[labels removeObjectAtIndex:idx];
	[enables removeObjectAtIndex:idx];
	[lines removeObjectAtIndex:idx];
}

-(void) disableInstance: (id<Reporter>) inst  
{
	int idx = [instances indexOfObject:inst];
	[enables replaceObjectAtIndex:idx withObject:[NSNumber numberWithBool:NO]];
}

- (void) clear
{
	[instances removeAllObjects];
	[labels removeAllObjects];
	[lines removeAllObjects];
	[enables removeAllObjects];
}

- (void) readFromDefaults
{
	Context *ctx = [Context sharedContext];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSArray *names = [ud objectForKey:@"hudInstances"];
	if (!names){
		return; // don't step on empty settings 
	}
	for (NSString *name in names){
		id<Reporter> inst = [ctx.instancesMap objectForKey:name];
		[instances addObject:inst];
	}
	labels = [ud objectForKey:@"hudLabels"];
	enables = [ud objectForKey:@"hudEnables"];
	lines = [ud objectForKey:@"hudHeights"];
}

- (void) saveToDefaults
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if ([instances count] == 0){
		[ud removeObjectForKey:@"hudInstances"];
		[ud removeObjectForKey:@"hudLabels"];
		[ud removeObjectForKey:@"hudHeights"];
		[ud removeObjectForKey:@"hudEnables"];
	}
	NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:[instances count]];
	for (id<Reporter> inst in instances){
		[names addObject:inst.name];
	}
	[ud setObject: names forKey:@"hudInstances"];
	[ud setObject:labels forKey:@"hudLabels"];
	[ud setObject:lines forKey:@"hudHeights"];
	[ud setObject:enables forKey:@"hudEnables"];
}
/*****
 Implement table to display this data
 *****/
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSInteger ret = [instances count];
	return ret;
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
	NSParameterAssert(instances != nil);
	NSParameterAssert(row >= 0 && row < [instances count]);
	
	NSString *colName = [tableColumn identifier];

	if ([colName isEqualToString:@"RPT"]){
		id<Reporter> rpt  = [instances objectAtIndex:row];
		theValue = rpt.name;
	} else if ([colName isEqualToString:@"HGT"]){
		NSNumber *hgt  = [lines objectAtIndex:row];
		theValue = hgt;
	} else if ([colName isEqualToString:@"SHOW"]){
		NSNumber *on  = [enables objectAtIndex:row];
		theValue = on;
	} else if ([colName isEqualToString:@"LABEL"]){
		NSString *label  = [labels objectAtIndex:row];
		theValue = label;
	}
    return theValue;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)col 
			  row:(NSInteger)row
{
	NSParameterAssert(row >= 0 && row < [instances count]);
	
	NSString *colName = [col identifier];
	
	if ([colName isEqualToString:@"HGT"]){
		[lines replaceObjectAtIndex:row withObject:anObject];
	} else if ([colName isEqualToString:@"SHOW"]){
		id<Reporter> rpt = [instances objectAtIndex:row];
		if (rpt.enabled == NO){
			NSAlert *alert = [NSAlert alertWithMessageText:@"Apologies" 
											 defaultButton:nil alternateButton:nil 
											   otherButton:nil 
								 informativeTextWithFormat:@"You can not enable HUD display for a disabled reporting plugin instance. Enable the plugin instance and try again."];
			[alert runModal];
		} else{
			[enables replaceObjectAtIndex:row withObject:anObject];
		}
	} else if ([colName isEqualToString:@"LABEL"]){
		[labels replaceObjectAtIndex:row withObject:anObject];
	}
}

- (NSDragOperation)tableView:(NSTableView *)aTableView 
				validateDrop:(id < NSDraggingInfo >)info 
				 proposedRow:(NSInteger)row 
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	return NSDragOperationEvery;
}

- (NSMutableArray*) moveItemsInArrayAbove:(NSMutableArray*) array 
						   indexes:(NSIndexSet*) indexes
							target: (NSUInteger) row	
{
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[array count]];
	// copy all the (non-move) items up to (but not including) the target to temp array
	for (NSUInteger idx = 0; idx < row; idx++){
		if (![indexes  containsIndex:idx])
			[temp addObject:[array objectAtIndex:idx]];
	}
	// copy the move items to the array
	for (NSUInteger idx = 0; idx < [array count]; idx++){
		if ([indexes  containsIndex:idx]){
			[temp addObject:[array objectAtIndex:idx]];
		}
	}
	// copy the target and following (non-move) items to the array
	for (NSUInteger idx = row; idx < [array count]; idx++){
		if (![indexes  containsIndex:idx]){
			[temp addObject:[array objectAtIndex:idx]];
		}
	}	
	return temp;
}

- (NSMutableArray*) moveItemsInArrayAt:(NSMutableArray*) array 
						indexes:(NSIndexSet*) indexes
					   target: (NSUInteger) row	
{
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[array count]];
	// copy all the (non-move) items up to and including the target to temp array
	for (NSUInteger idx = 0; idx <= row; idx++){
		if (![indexes  containsIndex:idx])
			[temp addObject:[array objectAtIndex:idx]];
	}
	// copy the move items to the array
	for (NSUInteger idx = 0; idx < [array count]; idx++){
		if ([indexes  containsIndex:idx]){
			[temp addObject:[array objectAtIndex:idx]];
		}
	}
	// copy the target-following (non-move) items to the array
	for (NSUInteger idx = row+1; idx < [array count]; idx++){
		if (![indexes  containsIndex:idx]){
			[temp addObject:[array objectAtIndex:idx]];
		}
	}
	return temp;
}

- (NSMutableArray*) moveItemsInArray: (NSMutableArray*) array 
					   moveOp: (NSTableViewDropOperation) op 
					  indexes:(NSIndexSet*) indexes
					 location: (NSUInteger) row		
{
	
	//NSTableViewDropOn,
	//NSTableViewDropAbove
	if (op == NSTableViewDropAbove)
		return [self moveItemsInArrayAbove: array 
								   indexes: indexes
									target: row];	
	if (op == NSTableViewDropOn)
		return [self moveItemsInArrayAt: array 
								indexes: indexes
								 target: row];
	return nil;
}


- (BOOL)tableView:(NSTableView *)aTableView 
	   acceptDrop:(id < NSDraggingInfo >)info 
			  row:(NSInteger)row 
	dropOperation:(NSTableViewDropOperation)op
{
	if (info.draggingSource == aTableView){
	
		NSPasteboard* pboard = [info draggingPasteboard];
		NSData* rowData = [pboard dataForType:[[HUDSettings class] description]];
		NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
		
		// Move the specified row to its new location...
		NSArray *temp = [self moveItemsInArray: instances 
									moveOp:  op 
								   indexes: rowIndexes
								  location:  row];
		for(int i = 0;i < [temp count];i++){
			[instances replaceObjectAtIndex:i withObject:[temp objectAtIndex:i]];
		}
		temp = [self moveItemsInArray: labels 
								 moveOp:  op 
								indexes: rowIndexes
							   location:  row];
		for(int i = 0;i < [temp count];i++){
			[labels replaceObjectAtIndex:i withObject:[temp objectAtIndex:i]];
		}	
		temp = [self moveItemsInArray: enables 
								  moveOp:  op 
								 indexes:  rowIndexes
								location:  row];
		for(int i = 0;i < [temp count];i++){
			[enables replaceObjectAtIndex:i withObject:[temp objectAtIndex:i]];
		}
		temp = [self moveItemsInArray: lines 
								  moveOp:  op 
								 indexes:  rowIndexes
								location:  row];
		for(int i = 0;i < [temp count];i++){
			[lines replaceObjectAtIndex:i withObject:[temp objectAtIndex:i]];
		}	
		[aTableView reloadData];
		return YES;
	}
	return NO;
}

- (BOOL)tableView:(NSTableView *)tv 
writeRowsWithIndexes:(NSIndexSet *)rowIndexes 
	 toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:[[HUDSettings class] description]] owner:self];
    [pboard setData:data forType:[[HUDSettings class] description]];
    return YES;
}

- (NSString*) labelForInstance: (id<Instance>) inst{
    int idx = [instances indexOfObject:inst];
    return [labels objectAtIndex:idx];
}

@end
