//
//  iCalTodoHandler.m
//  Self-Imposed Structure
//
//  Created by Charles on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iCalTodoHandler.h"
#define TASK_DUE @"due_time"
#define TASK_PRIORITY @"priority"
#define TASK_NOTES @"summary"
#define TASK_SUMMARY @"name"
#define TASK_URL @"url"
#define TASK_ID @"id"

@implementation iCalTodoHandler
@synthesize iCalDateFmt;
- (id) init
{
	self = [super init];
	if (self)
	{
		iCalDateFmt = [[NSDateFormatter new]retain];
		[iCalDateFmt setDateFormat:@"EEEE, MMMM dd, yyyy hh:mm:ss a"];
	}
	return self;
}

- (void) handleItemDescriptor:(NSAppleEventDescriptor*) descN list: (NSMutableArray*) eventsList
{
    NSMutableDictionary *eDict = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
	
    for(unsigned int j = 1; j <= [descN numberOfItems]; j+=2){
        //NSLog(@"descN[%d]", j);
        NSAppleEventDescriptor *fieldNameDesc = [descN descriptorAtIndex:j];
        NSAppleEventDescriptor *fieldValDesc = [descN descriptorAtIndex:j+1];
        
        // typeType (aka '    ') means the result is an empty string (which means nil in this case)
        if ([fieldValDesc descriptorType] != typeType) {
            
            NSString *fieldName = [fieldNameDesc stringValue];
            if ([fieldName isEqualToString:@"due"]){
                NSString *dateTemp = [fieldValDesc stringValue];
                NSDate *date = [iCalDateFmt dateFromString:dateTemp];
                [eDict setValue:date forKey:TASK_DUE];
            }       
            if ([fieldName isEqualToString:@"desc"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:TASK_NOTES];
            } 
			if ([fieldName isEqualToString:@"pri"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:TASK_PRIORITY];
            } 
            if ([fieldName isEqualToString:@"sum"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:TASK_SUMMARY];
            } 
            if ([fieldName isEqualToString:@"unique"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:TASK_ID];
            } 
        }
    }
    [eventsList addObject:eDict];                 
}


#define NILSCRIPT '    '
- (void) handleEventDescriptor: (NSAppleEventDescriptor*) aDescriptor list: (NSMutableArray*) eventsList
{
    char *c = nil;
    DescType type = [aDescriptor descriptorType];
    if (type == typeAERecord) {
        [self handleItemDescriptor:aDescriptor list: eventsList];
    }
    else if (type == typeAEList) {
        NSAssert(type == typeAEList, @"not a list!");
        for(unsigned int i = 1; i <= [aDescriptor numberOfItems]; i++){
            NSAppleEventDescriptor *descN = [aDescriptor descriptorAtIndex:i];
            DescType typeN = [descN descriptorType];
            NSAssert(typeN == typeAERecord, @"not a record");
            c = (char*)&type;
            //NSLog(@"descN[%d] = %c%c%c%c (%@)",i, c[3],c[2],c[1],c[0], [descN description]);
            for(unsigned int j = 1; j <= [descN numberOfItems]; j++){
                AEKeyword kw = [descN keywordForDescriptorAtIndex:j];
                NSAppleEventDescriptor *fdesc0 = [descN descriptorForKeyword:kw];
                //  DescType fldDesc = [fdesc0 descriptorType];
                [self handleItemDescriptor:fdesc0 list: eventsList];
                
            }
        }
    }
    else {
        c = (char*)&type;
        //NSLog(@"unexpected event descriptor: %c%c%c%c (%@)",c[3],c[2],c[1],c[0], [aDescriptor description]);
    }
    NSLog(@"processed %d events", [eventsList count]);
}
- (void) dealloc
{
    [iCalDateFmt release];
	[super dealloc];
}


@end
