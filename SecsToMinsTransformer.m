//
//  SecsToMinsTransformer.m
//  WorkPlayAway
//
//  Created by Charles on 2/12/11.
//  Copyright 2011 WorkPlayAway. All rights reserved.
//

#import "SecsToMinsTransformer.h"


@implementation SecsToMinsTransformer

+ (Class)transformedValueClass {
    return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
	if (value != nil)
	{
		float s = [value floatValue];  
		float m = s / 60;      
		return [NSNumber numberWithFloat:m]; 
	}
	return [NSNumber numberWithFloat:0.0];    
}

- (id)reverseTransformedValue:(id)value {
	if (value != nil)
	{
		float m = [value floatValue];         
		float s = m * 60; 
		return [NSNumber numberWithFloat:s];  
	}
	return [NSNumber numberWithFloat:0.0];    
}

@end
