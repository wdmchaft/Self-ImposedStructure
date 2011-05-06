//
//  SummaryHudControl.m
//  Self-Imposed Structure
//
//  Created by Charles on 1/18/11.
//  Copyright 2011 zer0gravitas. All rights reserved.
//

#import "SummaryHUDControl.h"
#import "WPADelegate.h"
#import "Context.h"
#import "TaskList.h"
#import "Instance.h"
#import "Reporter.h"
#import <BGHUDAppKit/BGHUDAppKit.h>
#import "SummaryViewController.h"

@implementation SummaryHUDControl
@synthesize controls,busys, datas, svcs;
@synthesize lineHeight;
@synthesize mainControl;

@synthesize view;
@synthesize frameData;
@synthesize sizedCount;
@synthesize framePos;
@synthesize viewChanged;
@synthesize buildTimer;
@synthesize saveRect;
@synthesize oneLastTime;

+ (void) initialize
{
    NSRect mRect = [NSScreen mainScreen].frame;
    CGFloat centerX = (mRect.size.width / 2);
    CGFloat centerY = (mRect.size.height / 2);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:centerX],		@"hudCenterX",
								[NSNumber numberWithDouble:centerY],		@"hudCenterY",
								 nil];
	
    [defaults registerDefaults:appDefaults];
}

- (id) initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	if (self){
		framePos = [window stringWithSavedFrame];
	}
	return self;
}

- (void) showWindow:(id)sender
{
	saveRect = NSMakeRect(0,0,0,0);
	[super showWindow:sender];
	NSDateFormatter *fmttr = [NSDateFormatter new];
	[fmttr setDateStyle:NSDateFormatterMediumStyle];
	[fmttr setTimeStyle:NSDateFormatterShortStyle];
	[super.window setTitle:[fmttr stringForObjectValue:[NSDate date]]];
	mainControl = sender; 
	NSString *pos = [[NSUserDefaults standardUserDefaults] objectForKey: @"posHUD"];
	//NSLog(@"loading framePos: %@", pos);

	[[super window] setFrameFromString:pos];
	[super.window makeKeyAndOrderFront:nil];
	NSRect currRect = [[super window] frame];
	CGFloat hgtTemp = [self calcHeight];
	currRect.size.height = hgtTemp;	
	[[super window] setContentSize: currRect.size];
	NSUInteger hudCount = [[[Context sharedContext].hudSettings allEnabled] count];
	
	NSRect rects[hudCount];
	for (int i = 0;i < hudCount;i++){
		NSRect nilRect = NSMakeRect(0, 0, 0, 0);
		rects[i] = nilRect;
	}
	frameData = [NSMutableData dataWithBytes:rects length:sizeof(NSRect)*hudCount];
	controls = [NSMutableDictionary dictionaryWithCapacity:hudCount];
	datas = [NSMutableDictionary dictionaryWithCapacity:hudCount];
	busys = [NSMutableDictionary dictionaryWithCapacity:hudCount];
	svcs = [NSMutableDictionary dictionaryWithCapacity:hudCount];
	viewChanged = YES;
	[self buildDisplay];
	[self setSizedCount:0];
}

- (void) windowDidLoad
{
	[super.window makeKeyAndOrderFront:nil];
	
}

- (double) preCalc: (NSArray*) data forSetting: (HUDSetting*) setting
{
	int actualLines = [data count];
	int lines = (actualLines > [setting height]) ? [setting height] : actualLines;
	int height = lines * (17);
		//	NSLog(@"maxLines = %d actualLines = %d height = %d for %@", maxLines, actualLines, height, reporter.name);
	return height;
	
}

/*** 
 the display is just a stack of nsboxes containing tables.  Each table has a maximum size, but if there are fewer 
 rows it could be smaller. and if the table is empty then it will not display nor will its surrounding box.
 buildDisplay will launch the summaryviewcontrollers for each table.  Each time the controllers either get an initial response or are complete the refreshDisplay method is called.
 ***/

- (void) buildDisplay 
{
	NSLog(@"buildDisplay");
	buildTimer = nil;
	
	// 
	// this code is heinous b/c I am probably just taking a totally wrong approach.  The HUD starts off showing
	// busy views for each reporter.  When the data for each view is acquired the busy view is replaced by the
	// appropriate table.  The table is probably bigger (taller) than the busy view and the HUD needs to expand
	// to the appropriate size to accomodate the tables (but no bigger)
	//
	// What makes this complicated:
	// You have to pre calculate how big the view is going to be (and size it) before rendering the tables.  
	// If you wait until after the tables are sized to set the HUD size you get strange problems --
	//
	// For example if you create a table whose origin is @ y = 5 -- but then you increase the HUD size by 20 
	// then the effective origin of the table is @ y = 25 -- the HUD view grows from the bottom - not the top
	//
	// also we try to minimize frame set actions because it makes the view flash in annoying manner.
	//
	
	BOOL needsFrameChange = NO;
	NSRect currRect = [[super window] frame];
	NSArray *settings = [[Context sharedContext].hudSettings allEnabled];
    // build it from the bottom of the list up because of the way screen coordinates work in cocoa
	NSRect winRect = [[super window] frame];
    CGFloat viewWidth = winRect.size.width - 10;
	CGFloat totalHeight = 14 * 1.5;
	NSUInteger nSettings = [settings count];
	BOOL lastDisplay = sizedCount == nSettings;
	NSRect rects[nSettings];
	[frameData getBytes:&rects length:sizeof(NSRect) * nSettings];
	for (int i = nSettings;i > 0;i--){
		//	NSLog(@"loop %d",i-1);
		HUDSetting *setting = [settings objectAtIndex:i-1];
		id<Reporter> rpt = setting.reporter; 
		NSString *rptName = [rpt name];
		HUDBusy *busy = [busys objectForKey:rptName];
		NSBox *control = [controls objectForKey:rptName];
		NSMutableArray *data = [datas objectForKey:rptName];
		if (data) {
			CGFloat dataTemp = [self preCalc:data forSetting:setting] + 28;
			totalHeight += dataTemp;
			NSLog(@"height for data %d %f", [data count], dataTemp );
		} 
		else if ((data == nil && busy == nil) || (busy)) {
			totalHeight += lineHeight * 3;
			NSLog(@"height for busy");
		}
		if (busy){
			[[busy view]setHidden:YES];
		}
		if (control) {
			[control setHidden:YES];
		}
		
	}	
	currRect.size.height = totalHeight;
	if (!NSEqualRects(currRect, saveRect)){
		NSLog(@"resizing window bc %@ != %@", NSStringFromRect(currRect),NSStringFromRect(saveRect	));
		[[super window] setContentSize: currRect.size];
		saveRect = currRect;
		needsFrameChange = YES;
	}
	
	totalHeight = lineHeight * 1.5;

	for (int i = nSettings;i > 0;i--){
	//	NSLog(@"loop %d",i-1);
		HUDSetting *setting = [settings objectAtIndex:i-1];
		id<Reporter> rpt = setting.reporter; 
		NSString *rptName = [rpt name];
		NSBox *control = [controls objectForKey:rptName];
		HUDBusy *busy = [busys objectForKey:rptName];
		NSMutableArray *data = [datas objectForKey:rptName];
		SummaryViewController *svc = [svcs objectForKey:rptName];
		NSRect rect = rects[i-1];
	//	NSLog(@"loop %d %@",i, svc);
		
		if (data && control == nil){
			[[busy view] removeFromSuperview];
			[busys removeObjectForKey:rptName];
			busy = nil;
			// create table view control/box and add it to the view
			svc = [self getViewForInstance:rpt width:viewWidth rows:setting.height];
			[svcs setObject: svc forKey:rptName];
			[svc setData: data];
			
			NSBox *box = [[BGHUDBox alloc] initWithFrame:winRect];
			[controls setObject:box forKey:rptName];
			NSSize margins; margins.height = 0; margins.width = 0;
			[box setContentViewMargins:margins];
			[box setContentView:svc.view];
			NSDictionary *attrs = [NSDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
			NSString *titleStr = [[NSAttributedString alloc]initWithString:setting.label 
																attributes:attrs];
			[box setTitle:titleStr];
			[box setTitlePosition:NSAboveTop];
			[box setBoxType:NSBoxSecondary];
			[view addSubview:box];
			control = box;
		}
		if (svc) {
			[control setHidden:NO];
			[[svc view] setHidden:NO];
			//	[svc.table setHidden:NO];
			NSRect boxFrame;
			lineHeight = [svc.table rowHeight];
			//NSLog(@"before totalheight = %f for %@", totalHeight, [rpt name]);
			boxFrame.origin.y = totalHeight;
			boxFrame.origin.x = 7;
			boxFrame.size.width = winRect.size.width - 10;
			boxFrame.size.height = [svc actualHeight] + (lineHeight * 2);
			
			NSRect contentFrame = boxFrame;
			contentFrame.size.height = [svc actualHeight];
			if (NSEqualRects(rect,contentFrame) == NO || needsFrameChange) {
				NSLog(@"resizing SVC");
				[control setFrameFromContentFrame:contentFrame];
				
				[svc.view setFrame:[control.contentView bounds]];
				rects[i-1] = contentFrame;
				[svc.view setNeedsDisplay:YES];
				
			}
			
			
			totalHeight += boxFrame.size.height;			
			//	NSLog(@"after totalheight = %f for %@", totalHeight, [rpt name]);
		}
		
		if (data == nil && busy == nil)
		{
			// create busy control and add it to the view
			NSLog(@"creating busy for %@", rptName);
			busy = [[HUDBusy alloc]initWithNibName:@"HUDBusyView" bundle:[NSBundle mainBundle]];
			[view addSubview:[busy view]];
			[busy setReporter:rpt];
			[busy setCaller:self];
			[[busy label] setStringValue:[rpt summaryTitle]]; 
			[busys setObject:busy forKey:rptName];
			[busy refresh];
		}
		if (busy) {
			[[busy view] setHidden:NO];
			NSRect busyRect = [[busy view] frame];
			busyRect.origin.y = totalHeight;
			busyRect.origin.x = 5;
			busyRect.size.width = winRect.size.width - 10;
			if (NSEqualRects(rect,busyRect) == NO || needsFrameChange) {
				NSLog(@"moving busy %@ from %f to %f", [rpt summaryTitle], rect.origin.y, busyRect.origin.y);
				[[busy prog] stopAnimation:self];
				[[busy view] setFrame: busyRect];
				[[busy view] setNeedsDisplay:YES];
				[view setNeedsDisplay:YES];
				[[busy prog] startAnimation:self];
				rects[i-1] = busyRect;
			}
			totalHeight += busyRect.size.height + lineHeight;
		}
		}
	if (needsFrameChange) {
		currRect.size.height = totalHeight;	
	//	NSLog(@"new height = %f", totalHeight);
//		[[super window] setContentSize: currRect.size];
//		currRect.size.height += 15; // for titlebar height	
//		[[super window] setFrame: currRect display:NO];
		[view setNeedsDisplay:YES];
	}
	if (lastDisplay) {
		// run the build just one more time since nothing will have changed
		if (!oneLastTime) {
			buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(buildDisplay) userInfo:nil repeats:NO];
			oneLastTime = YES;
		} else {
			NSLog(@"sizedCount = %d - display is complete!", sizedCount);
		}
	} else{
		buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(buildDisplay) userInfo:nil repeats:NO];
	} 
	NSRange range; 
	range.length = sizeof(NSRect) * nSettings;
	range.location = 0;
	[frameData replaceBytesInRange:range withBytes:rects]; 
	viewChanged = NO;
}
	

#define LINE_HGT 14
- (CGFloat) calcHeight{
	NSArray *settings = [[Context sharedContext].hudSettings allEnabled];
	CGFloat totalHeight = LINE_HGT;
	for (int i = [settings count] - 1;i >= 0;i--){
		HUDSetting *setting = [settings objectAtIndex:i];
		totalHeight += ([setting height] + 2) * (LINE_HGT);
	}
    totalHeight += LINE_HGT;
	return totalHeight;
}
- (void) windowWillClose:(NSNotification *)notification
{
	if (buildTimer){
		[buildTimer invalidate];
		buildTimer = nil;
	}
}
- (void) viewSized: (NSView*) retView reporter: (id<Reporter>) rpt data: (NSArray*) array
{
	NSLog(@"viewSized for %@", rpt.name);
	//[retView setHidden:YES];
	//[retView removeFromSuperview];
	[datas setObject:array forKey:[rpt name]];
	//[busys removeObjectForKey: [rpt name]];
	viewChanged = YES;
	sizedCount++;
}

- (void)windowDidMove:(NSNotification *)aNotification
{
	framePos = [[self window] stringWithSavedFrame];
	//NSLog(@"setting framePos: %@", framePos);
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (SummaryViewController*) getViewForInstance: (id<Reporter>) inst width: (CGFloat) vWidth rows: (int) nRows
{
	NSString *rptNib;
	SummaryViewController *temp = nil;
	switch (inst.category) {
		case CATEGORY_EMAIL:
			rptNib = @"MailTableView";
			temp = [[SummaryMailViewController alloc] initWithNibName: rptNib 
															   bundle:[NSBundle mainBundle]];
			[temp setReporter:inst];
			[temp setWidth:vWidth];
			[temp setMaxLines:nRows];
			break;
		case CATEGORY_TASKS:
			rptNib = @"TaskTableView";
			temp = [[SummaryTaskViewController alloc] initWithNibName: rptNib 
															   bundle:[NSBundle mainBundle] ];

			[temp setReporter:inst];
			[temp setWidth:vWidth];
			[temp setMaxLines:nRows];
			break;
		case CATEGORY_EVENTS:
			rptNib = @"EventTableView";
			temp = [[SummaryEventViewController alloc] initWithNibName: rptNib 
																bundle:[NSBundle mainBundle] ];
			[temp setReporter:inst];
			[temp setWidth:vWidth];
			[temp setMaxLines:nRows];			
		break;
		default:
			break;	
	}
	return temp;
}

@end
