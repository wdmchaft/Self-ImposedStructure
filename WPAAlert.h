//
//  Alert.h
//  Self-Imposed Structure
//
//  Created by Charles on 11/18/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WPAAlert : NSObject {
	NSString* moduleName;
	BOOL urgent;
	NSString *title;
	NSString *message;
	NSDictionary *params;
	BOOL sticky;
	BOOL clickable;
	BOOL isWork;
	BOOL lastAlert;
}
@property (nonatomic, retain) NSString* moduleName;
@property (nonatomic)BOOL urgent;
@property (nonatomic)BOOL sticky;
@property (nonatomic)BOOL clickable;
@property (nonatomic)BOOL lastAlert;
@property (nonatomic)BOOL isWork;
@property (nonatomic ,retain)NSString *title;
@property (nonatomic ,retain)NSString *message;
@property (nonatomic ,retain)NSDictionary *params;

@end
