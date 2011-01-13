//
//  TimerDialogController.m
//  Nudge
//
//  Created by Charles on 12/13/10.
//  Copyright 2010 workplayaway.com. All rights reserved.
//

#import "TimerDialogController.h"
#import "Context.h"


@implementation TimerDialogController
@synthesize minutesField;
@synthesize alarmNames;
@synthesize okButton;

-(void) windowDidLoad
{
	Context *ctx = [Context sharedContext];
	[minutesField setStringValue:[NSString stringWithFormat:@"%d",ctx.thinkTime]];
	[self loadSoundNames];
}

-(void) showWindow:(id)sender
{
	Context *ctx = [Context sharedContext];
	[minutesField setStringValue:[NSString stringWithFormat:@"%d",ctx.thinkTime]];
	[self loadSoundNames];
}

-(void) loadSoundNames
{
	NSFileManager *dfm = [NSFileManager defaultManager];
	[alarmNames removeAllItems];
	NSError *err = [NSError new];
	NSString *soundsPath = [@"~/Library/Sounds" stringByExpandingTildeInPath];
	NSArray *fileNames = [dfm contentsOfDirectoryAtPath:soundsPath error: &err];
	for (NSString *fileName in fileNames){
		NSString *displayName = [[dfm displayNameAtPath:fileName] stringByReplacingOccurrencesOfString:@".aiff" withString:@""];
		if ([fileName hasSuffix:@".aiff"]){
			[alarmNames addItemWithTitle:displayName];
		}
	}
	soundsPath = @"/System/Library/Sounds";
	fileNames = [dfm contentsOfDirectoryAtPath:soundsPath error: &err];
	for (NSString *fileName in fileNames){
		NSString *displayName = [[dfm displayNameAtPath:fileName] stringByReplacingOccurrencesOfString:@".aiff" withString:@""];
		if ([fileName hasSuffix:@".aiff"]){
			[alarmNames addItemWithTitle:displayName];
		}
	}
	[alarmNames selectItemWithTitle:[Context sharedContext].alertName];
}

-(void) okClicked: (id) sender
{
	Context *ctx = [Context sharedContext];
	ctx.thinkTime = [minutesField intValue];
	ctx.alertName = [alarmNames titleOfSelectedItem];
	[ctx saveDefaults];
	[NSApp endSheet: [super window]];
	[super.window close];
}
@end
