//
//  VariableTableColumn.m
//  Self-Imposed Structure
//
//  Created by Charles on 3/27/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "VariableTableColumn.h"
#import "FilterRule.h"

@implementation VariableTableColumn
@synthesize keyColumn;
@synthesize dataSource;
@synthesize table;
@synthesize buttonCell;
@synthesize textCell;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithColumn: (NSTableColumn*) col
{
    if (self){
        [super setWidth:col.width];
        if ([col sortDescriptorPrototype]) {
            [super setSortDescriptorPrototype:[col sortDescriptorPrototype]];
        }
        [super setDataCell:col.dataCell];
        [super setEditable:col.isEditable];
        [super setHeaderCell:col.headerCell];
        if (col.headerToolTip){
            [super setHeaderToolTip:col.headerToolTip];
        }
        [super setHidden:col.isHidden];
        [super setIdentifier:col.identifier];
        [super setMaxWidth:col.maxWidth];
        [super setMinWidth:col.minWidth];
        [super setResizingMask:col.resizingMask];
        if (col.observationInfo){
            [super setObservationInfo:col.observationInfo];
        }
    }return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)dataCellForRow:(NSInteger)row
{
    NSNumber *fieldVal = [dataSource tableView:table objectValueForTableColumn:keyColumn row:row];
    if (fieldVal.intValue == FIELD_READSTATUS) {
        if (!buttonCell){
            buttonCell = [NSButtonCell new];
            [buttonCell setTitle:@"Unread"];
            [buttonCell setButtonType:NSSwitchButton];
            [buttonCell setEditable:YES];
        }
        return buttonCell;
    }else {
        if (!textCell){
            textCell = [NSTextFieldCell new];
            [textCell setEditable:YES];
            
        }
        return textCell;
    }
    
}
-(NSSortDescriptor*) sortDescriptorPrototype
{
    return nil;
}
@end
