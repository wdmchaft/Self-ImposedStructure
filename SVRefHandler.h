//
//  SVRefHandler.h
//  WorkPlayAway
//
//  Created by Charles on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlertHandler.h"

@protocol SVRefCtrl <NSObject>

- (void) endRefresh;

@end

@interface SVRefHandler : NSObject <AlertHandler> {
    
@private
    NSMutableArray *data;
    id<SVRefCtrl> ref;
}   

@property (nonatomic,retain)  NSMutableArray *data;
@property (nonatomic,retain) id<SVRefCtrl> ref;


@end
