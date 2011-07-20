//
//  RefreshableViewController.h
//  WorkPlayAway
//
//  Created by Charles on 7/19/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol Refreshable

- (void) refreshView;

@end


@interface RefreshableViewController : NSViewController <Refreshable>{

}

@end
