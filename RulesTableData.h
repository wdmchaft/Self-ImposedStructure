//
//  RulesTableData.h
//  Nudge
//
//  Created by Charles on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilterRule.h"
#define TYPE_COL @"Type"
#define FIELD_COL @"Field"
#define COMPARE_COL @"Compare"
#define VALUE_COL @"Value"


@interface RulesTableData : NSObject <NSTableViewDataSource> {
	NSMutableArray *allRules;
}
- (id) initWithRules: (NSArray*) data;
- (id) objValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger) row;

@property (nonatomic, retain) NSMutableArray* allRules;
@end

