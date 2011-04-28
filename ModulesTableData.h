//
//  ModulesTableData.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ModulesTableData : NSObject <NSTableViewDataSource> {
	NSMutableDictionary *instances;
}
- (ModulesTableData*) initWithDictionary: (NSMutableDictionary*) data;
- (id) objValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger) row;

@property (nonatomic, retain) NSMutableDictionary* instances;
@end
