//
//  ModulesTableData.h
//  Nudge
//
//  Created by Charles on 11/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ModulesTableData : NSObject <NSTableViewDataSource> {
	NSMutableDictionary *instances;
}
- (ModulesTableData*) initWithDictionary: (NSMutableDictionary*) data;
- (id) objValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger) row;

@property (nonatomic, retain) NSMutableDictionary* instances;
@end
