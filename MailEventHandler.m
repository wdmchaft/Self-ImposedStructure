//
//  AppleMailDaemon.m
//  WorkPlayAway
//
//  Created by Charles on 5/9/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "MailEventHandler.h"
#define MAIL_EMAIL @"email"
#define MAIL_SUMMARY @"summary"
#define MAIL_SUBJECT @"title"
#define MAIL_NAME @"name"
#define MAIL_ARRIVAL_TIME @"received"
#define MAIL_SENT_TIME @"issued"

@implementation MailEventHandler

@synthesize mailDateFmt;

- (id) init
{
	self = [super init];
	if (self)
	{
		mailDateFmt = [[NSDateFormatter new]retain];
		[mailDateFmt setDateFormat:@"EEEE, MMMM dd, yyyy hh:mm:ss a"];
	}
	return self;
}

- (void) handleMessageDescriptor:(NSAppleEventDescriptor*) descN list: (NSMutableArray*) newestMail
{
    NSMutableDictionary *eDict = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
    
    for(unsigned int j = 1; j <= [descN numberOfItems]; j+=2){
        NSLog(@"descN[%d]", j);
        NSAppleEventDescriptor *fieldNameDesc = [descN descriptorAtIndex:j];
        NSAppleEventDescriptor *fieldValDesc = [descN descriptorAtIndex:j+1];
        
        // typeType (aka '    ') means the result is an empty string (which means nil in this case)
        if ([fieldValDesc descriptorType] != typeType) {
			
            NSString *fieldName = [fieldNameDesc stringValue];
            if ([fieldName isEqualToString:@"rDate"]){
                NSString *dateTemp = [fieldValDesc stringValue];
                NSDate *date = [mailDateFmt dateFromString:dateTemp];
                [eDict setValue:date forKey:MAIL_ARRIVAL_TIME];
            }   
            if ([fieldName isEqualToString:@"sDate"]){
                NSString *dateTemp = [fieldValDesc stringValue];
                NSDate *date = [mailDateFmt dateFromString:dateTemp];
                [eDict setValue:date forKey:MAIL_SENT_TIME];
            }  
            if ([fieldName isEqualToString:@"subj"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_SUBJECT];
            } 
            if ([fieldName isEqualToString:@"cont"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_SUMMARY];
            } 
            if ([fieldName isEqualToString:@"unique"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:@"id"];
            } 
            if ([fieldName isEqualToString:@"sendr"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_NAME];
            } 
            if ([fieldName isEqualToString:@"mailr"]){
                [eDict setValue:[fieldValDesc stringValue] forKey:MAIL_EMAIL];
            } 
            if ([fieldName isEqualToString:@"stat"]){
                [eDict setValue:[NSNumber numberWithBool:[fieldValDesc booleanValue]] forKey:@"readStatus"];
            } 
        }
    }
    [newestMail addObject:eDict];                 
}

- (void) handleEventDescriptor: (NSAppleEventDescriptor*) aDescriptor list: (NSMutableArray*) newestMail
{
    char *c = nil;
    
	DescType type = [aDescriptor descriptorType];
	OSType osType = [aDescriptor enumCodeValue];
	AEEventClass evClass = [aDescriptor eventClass];
	c = (char*)&type;
	NSLog(@"code = %d class = %d event descriptor: %c%c%c%c (%@)", osType, evClass, c[3],c[2],c[1],c[0], [aDescriptor description]);
	
	if (osType == 0){
        //NSLog(@"Script return enumCodeValue indicates error");
		return;
	}
    if (type == typeAERecord) {
        [self handleMessageDescriptor:aDescriptor list:newestMail];
    }
    else if (type == typeAEList) {
        for(unsigned int i = 1; i <= [aDescriptor numberOfItems]; i++){
            NSAppleEventDescriptor *descN = [aDescriptor descriptorAtIndex:i];
            DescType typeN = [descN descriptorType];
			if (typeN == typeAERecord) {
				
				for(unsigned int j = 1; j <= [descN numberOfItems]; j++){
					AEKeyword kw = [descN keywordForDescriptorAtIndex:j];
					NSAppleEventDescriptor *fdesc0 = [descN descriptorForKeyword:kw];
					[self handleMessageDescriptor:fdesc0 list:newestMail];
				}
			} else {
				c = (char*)&typeN;
				//NSLog(@"Ignoring descN[%d] = %c%c%c%c (%@)",i, c[3],c[2],c[1],c[0], [descN description]);
			}
        }
    }
    else {
        c = (char*)&type;
        //NSLog(@"unexpected event descriptor: %c%c%c%c (%@)",c[3],c[2],c[1],c[0], [aDescriptor description]);
    }
}

- (void) dealloc
{
	[mailDateFmt release];
	[super dealloc];
}
@end

