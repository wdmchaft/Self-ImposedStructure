//
//  TimerDialogController.m
//  Nudge
//
//  Created by Charles on 12/13/10.
//  Copyright 2010 zer0gravitas.com. All rights reserved.
//

#import "TimerDialogController.h"
#import "Context.h"


@implementation TimerDialogController
@synthesize minutesField;
@synthesize alarmNames;
@synthesize okButton;

-(void) windowDidLoad
{
//	[minutesField setIntValue:(ctx.thinkTime / 60)];
	[self loadSoundNames];
    [[super window] setFrameAutosaveName:@"Timer"];
}

-(void) showWindow:(id)sender
{
	Context *ctx = [Context sharedContext];
	[minutesField setIntValue:(ctx.thinkTime / 60)];
	[self loadSoundNames];
	[[super window]setLevel:NSFloatingWindowLevel];
	[super showWindow:sender];
}

- (void) close
{
	[NSApp stopModal];
}

- (void) windowWillClose:(NSNotification *)notification
{
	[NSApp stopModal];
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
	NSString *alertName = [[NSUserDefaults standardUserDefaults] stringForKey:@"alertName"];
	[alarmNames selectItemWithTitle:alertName];
}

-(void) okClicked: (id) sender
{
	Context *ctx = [Context sharedContext];
	ctx.thinkTime = ([minutesField intValue] * 60);
	[[NSUserDefaults standardUserDefaults] setFloat:ctx.thinkTime forKey:@"thinkTime"];
	[[NSUserDefaults standardUserDefaults] setObject:[alarmNames titleOfSelectedItem] forKey:@"alertName"];
	
	[ctx saveDefaults];
	[NSApp stopModal];
	[super.window close];
}
@end
