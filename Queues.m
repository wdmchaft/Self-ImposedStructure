//
//  Queues.m
//  Self-Imposed Structure
//
//  Created by Charles on 6/1/11.
//  Copyright 2011 zer0gravitas.com All rights reserved.
//

#import "Queues.h"


@implementation Queues

+ (NSString*) queueNameFor: (NSString*) type fromBase: (NSString*) base
{
	return [base stringByAppendingFormat:@".%@",type];
}


@end
