//
//  VariableTableColumn.h
//  WorkPlayAway
//
//  Created by Charles on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VariableTableColumn : NSTableColumn {
@private
    id<NSTableViewDataSource> dataSource;
    NSTableColumn *keyColumn;
    NSTableView *table;
    NSButtonCell *buttonCell;
    NSTextFieldCell *textCell;
}
@property (nonatomic, retain) id<NSTableViewDataSource> dataSource;
@property (nonatomic, retain) NSTableView* table;
@property (nonatomic, retain) NSButtonCell* buttonCell;
@property (nonatomic, retain) NSTextFieldCell* textCell;
@property (nonatomic, retain) NSTableColumn *keyColumn;
- (id) initWithColumn: (NSTableColumn*) col;

@end
