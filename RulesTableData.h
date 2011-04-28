//
//  RulesTableData.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/3/11.
//  Copyright 2011 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FilterRule.h"
#define TYPE_COL @"Type"
#define FIELD_COL @"Field"
#define COMPARE_COL @"Compare"
#define VALUE_COL @"Value"
#define COLOR_COL @"Clr"


@interface RulesTableData : NSObject <NSTableViewDataSource> {
	NSMutableArray *allRules;
    NSButtonCell *boolCell;
    NSTableColumn *predCol;
}
- (id) initWithRules: (NSArray*) data;
- (id) objValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger) row;

@property (nonatomic, retain) NSMutableArray* allRules;
@property (nonatomic, retain) NSButtonCell* boolCell;
@property (nonatomic, retain) NSTableColumn* predCol;
@end

