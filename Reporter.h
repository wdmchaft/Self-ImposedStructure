//
//  Reporter.h
//  Self-Imposed Structure
//
//  Created by Charles on 1/23/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Instance.h"
#define EVENT_START @"start"
#define EVENT_END @"end"
#define EVENT_DESC @"desc"
#define EVENT_SUMMARY @"summary"
#define EVENT_ID @"id"
#define TASK_DUE @"due_time"
#define TASK_NAME @"name"
#define REPORTER_MODULE @"module"
#define MAIL_EMAIL @"email"
#define MAIL_SUMMARY @"summary"
#define MAIL_SUBJECT @"title"
#define MAIL_NAME @"name"
#define MAIL_ARRIVAL_TIME @"received"
#define MAIL_SENT_TIME @"issued"
#define MAIL_COLOR @"color"

@protocol Reporter <Instance>
@required
// implement these two to provide status information (email/events/tasks)
- (void) refresh: (id<AlertHandler>) handler isSummary: (BOOL) summary;
- (void) handleClick: (NSDictionary*) params;
- (void) initSummaryTable: (NSTableView*) view;

@property (nonatomic, retain) NSString* notificationName;
@property (nonatomic, retain) NSString* notificationTitle;
@property (nonatomic) NSTimeInterval refreshInterval;
@property (nonatomic, retain) NSString *summaryTitle;
@end
