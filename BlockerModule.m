//
//  BlockerModule.m
//  WorkPlayAway
//
//  Created by Charles on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlockerModule.h"
#define BLOCKCOUNT @"BlockCount"
#define BLOCK @"Block"

@implementation BlockerModule
@synthesize blackList;
@synthesize addButton,removeButton, listBrowser;

-(void) think
{
	thinking = YES;
	[self block];
}
-(void) putter;
{
	thinking = NO;
	[self unblock];
}
-(void) stop
{
	[self unblock];
}

-(void) start
{
	
}

-(void) goAway
{
	away = YES;
	thinking = NO;
	[self unblock];
}

-(void) startValidation: (NSObject*) callback  
{
	validationHandler = callback;
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [ myBundle pathForAuxiliaryExecutable: SWITCHER];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL exists = [fm fileExistsAtPath:path];
	if (!exists){
		NSString *msg = [NSString stringWithFormat:@"Switcher executable not found at: %@",path];
		[validationHandler performSelector:@selector(validationComplete:) 
								withObject:msg];
	}
	NSError *errInfo;
	NSDictionary *attrs = [fm attributesOfItemAtPath:path error:&errInfo];
	NSString *owner = [attrs fileOwnerAccountName];
	if (![owner isEqualToString: @"root"]){
		NSString *msg = [NSString stringWithFormat:@"Switcher executable at [%@] is not owned by root",path];
		[validationHandler performSelector:@selector(validationComplete:) 
							withObject:msg];
	}
	NSUInteger perms = [attrs filePosixPermissions];
	if (!(perms & 04010)) {
		NSString *msg = [NSString stringWithFormat:@"Switcher at [%@] does not have execute as root permissions",path];
		[validationHandler performSelector:@selector(validationComplete:) 
								withObject:msg];
	}
	[validationHandler performSelector:@selector(validationComplete:) 
							withObject:nil];
}

- (void) block 
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *switcherPath = [ myBundle pathForAuxiliaryExecutable: SWITCHER];
	NSString *resourceDir = [myBundle resourcePath ];
	NSString *blockerFilePath = [NSString stringWithFormat:@"%@/%@",resourceDir,BLOCKERFILE];
	NSString *backupFilePath = [NSString stringWithFormat:@"%@/%@",resourceDir,BACKUPFILE];
	NSString *buf = [NSString new];
	for (NSString *host in blackList){
		buf = [buf stringByAppendingFormat:@"%@\n", host];
	}
	NSError *errInfo;
	[buf writeToFile:blockerFilePath atomically:YES encoding:NSUTF8StringEncoding error:&errInfo];
	NSTask *task = [NSTask launchedTaskWithLaunchPath:switcherPath arguments:[NSArray
																			  arrayWithObjects:blockerFilePath, backupFilePath, nil]];
	[task waitUntilExit];
	int res = [task terminationStatus];
	if (res != 0) {
		switch(res){
			case 1:
				[super sendError:@"Error reading hosts file" module:[self description]];
				break;
			case 2:
				[super sendError:@"Error writing backup file" module:[self description]];
				break;
			case 3:
				[super sendError:@"Error updating hosts file" module:[self description]];
				break;
		}
	}
	
}
- (void) unblock;
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *resourceDir = [myBundle resourcePath ];
	NSString *switcherPath = [ myBundle pathForAuxiliaryExecutable: SWITCHER];
	NSString *backupFilePath = [NSString stringWithFormat:@"%@/%@",resourceDir,BACKUPFILE];
	NSTask *task = [NSTask launchedTaskWithLaunchPath:switcherPath arguments:[NSArray
																			  arrayWithObjects: backupFilePath, nil]];
	[task waitUntilExit];
	int res = [task terminationStatus];
	if (res != 0) {
		switch(res){
			case 3:
				[super sendError:@"Error restoring original hosts file" module:[self description]];
				break;
		}
	}
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self){
		super.description =@"Blocker Module";
		super.notificationName = @"Blocker Alert";
		super.notificationTitle = @"Blocker Msg";
	}
	return self;
}

-(void) loadView
{
	[super loadView];
	listBrowser.dataSource = self;
	
}

-(void) loadDefaults
{
	[super loadDefaults];
	NSNumber *count = [super loadDefaultForKey:BLOCKCOUNT];
	for (int i = 0; i < [count intValue] ;i++) {
		NSString *key = [NSString stringWithFormat:@"%@_%d",BLOCK, i];
		NSString *site = [super loadDefaultForKey:key];
		if (!blackList)
			blackList = [NSMutableArray new];
		[blackList addObject: site];
	}
}


-(void) clearDefaults
{
	[super clearDefaults];

	for (int i = 0; i < [blackList count];i++) {
		NSString *key = [NSString stringWithFormat:@"%@_%d",BLOCK, i];
		[super clearDefaultValue:[blackList objectAtIndex:i] forKey:key];
	}
	[super clearDefaultValue:[NSNumber numberWithInt:[blackList count]] forKey:BLOCKCOUNT];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

-(void) saveDefaults
{
	[super saveDefaults];
	[super saveDefaultValue:[NSNumber numberWithInt:[blackList count]] forKey:BLOCKCOUNT];
	for (int i = 0; i < [blackList count];i++) {
		NSString *key = [NSString stringWithFormat:@"%@_%d",BLOCK, i];
		[super saveDefaultValue:[blackList objectAtIndex:i] forKey:key];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];		
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [blackList count];
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id theValue;
    NSParameterAssert(row >= 0 && row < [blackList count]);
    NSString *domains  = [blackList objectAtIndex:row];
	NSString *colName = (NSString*) [tableColumn identifier];
	if ([colName isEqualToString:DOMAIN_COL]){
		theValue = domains;
	}
    return theValue;
	
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(NSInteger)rowIndex
{	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [blackList count]);
	NSString *colName = (NSString*) [aTableColumn identifier];
	if ([colName isEqualToString:DOMAIN_COL]){
		[blackList replaceObjectAtIndex:rowIndex withObject:[anObject stringValue]];
	}
}

-(void) addClicked:(id)sender
{
	if (!blackList)
		blackList = [NSMutableArray new];
	[blackList addObject:@"www.someDomain.com"];
	[listBrowser noteNumberOfRowsChanged];
}

-(void) removeClicked:(id)sender
{
	NSInteger rowNum = listBrowser.selectedRow;
	if (rowNum > -1) {
		[blackList removeObjectAtIndex:rowNum];
		[listBrowser noteNumberOfRowsChanged];
	}
}
@end
