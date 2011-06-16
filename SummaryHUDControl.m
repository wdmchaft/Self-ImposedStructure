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
#import "Utility.h"
#import "Queues.h"
#import "StatusIconView.h"

@implementation SummaryHUDControl
@synthesize controls,busys, datas, svcs, titles;
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
@synthesize currentTaskView;
@synthesize totalsManager;
@synthesize useCache;

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
		[window setAllowsToolTipsWhenApplicationIsInactive:YES];
	}
	return self;
}

- (void) taskChanged: (NSNotification*) notification
{	
	[self buildDisplay];
}

- (void) dataChanged: (NSNotification*) msg
{
	NSLog(@"dataChanged: %@", msg);
	NSString *modName = [[msg userInfo]objectForKey:@"module"];
	NSMutableArray *data = [datas objectForKey:modName];
	[data removeAllObjects];
	[datas removeObjectForKey:modName];
	data = nil;

	[busys removeObjectForKey:modName];
	SummaryViewController *svc = [svcs objectForKey:modName];
	[[svc view] removeFromSuperview];
	[svcs removeObjectForKey:modName];
	NSView *title = [titles objectForKey:modName];
	[title removeFromSuperview];
	[titles removeObjectForKey:modName];
	NSView *box = [controls objectForKey:modName];
	[box removeFromSuperview];
	[controls removeObjectForKey:modName];
	sizedCount--;
	oneLastTime = NO;
	[self buildDisplay];
}

- (void) showWindow:(id)sender
{
	Context *ctx =[Context sharedContext];

	saveRect = NSMakeRect(0,0,0,0);
	[super showWindow:sender];
	NSDateFormatter *fmttr = [NSDateFormatter new];
	[fmttr setDateStyle:NSDateFormatterMediumStyle];
	[fmttr setTimeStyle:NSDateFormatterShortStyle];
	NSString *infoStr = @"";
	if ([ctx currentState] == WPASTATE_VACATION){
		infoStr = @"Vacation Day";
	} 
	else if ([totalsManager calcGoal] == 0.0){
		infoStr = @"Day Off";
	}
	else if ([totalsManager workToday] > [totalsManager calcGoal]){
		infoStr = @"Quittin' Time";
    } else {
		infoStr = @"Get Ta Work!";
	}

	NSString* titleStr = [NSString stringWithFormat:@"%@ -- %@",
						  [fmttr stringForObjectValue:[NSDate date]],
						  infoStr];
	[super.window setTitle: titleStr];
	mainControl = sender; 
	NSString *pos = [[NSUserDefaults standardUserDefaults] objectForKey: @"posHUD"];
	//NSLog(@"loading framePos: %@", pos);

	[[super window] setFrameFromString:pos];
	[super.window makeKeyAndOrderFront:nil];
//	NSSize resizeSize = NSMakeSize(0, 0);
//	[super.window setResizeIncrements:resizeSize];
	NSRect currRect = [[super window] frame];
	CGFloat hgtTemp = [self calcHeight];
	currRect.size.height = hgtTemp;	
	[[super window] setContentSize: currRect.size];
	NSUInteger hudCount = [[ctx.hudSettings allEnabled] count];
	
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
	titles = [NSMutableDictionary dictionaryWithCapacity:hudCount];
	viewChanged = YES;
	useCache = NO;
	[self buildDisplay];
	[self setSizedCount:0];
	NSString *updateQueue =  [Queues queueNameFor:WPA_UPDATEQUEUE fromBase:ctx.queueName];
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(dataChanged:) name:updateQueue object:nil];
	useCache = YES;
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
	[[self view] setAutoresizesSubviews:YES];
	BOOL needsFrameChange = NO;
	NSRect currRect = [[super window] frame];
	NSArray *settings = [[Context sharedContext].hudSettings allEnabled];
    // build it from the bottom of the list up because of the way screen coordinates work in cocoa
	NSRect winRect = [[super window] frame];
    CGFloat viewWidth = winRect.size.width;
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
			CGFloat dataTemp = [self preCalc:data forSetting:setting];
			// only add vertical spacer if there is data
			dataTemp += (dataTemp > 0) ? 5 : 0;
			totalHeight += dataTemp;
		} 
		else if ((data == nil && busy == nil) || (busy)) {
			totalHeight += lineHeight * 3;
		}
		if (busy){
			[[busy view]setHidden:YES];
		}
		if (control) {
			[control setHidden:YES];
		}
	}	
	Context *ctx = [Context sharedContext];
	totalHeight += 19.0; // for currentTask

	currRect.size.height = totalHeight;
	if (!NSEqualRects(currRect, saveRect)){
		//NSLog(@"resizing window bc %@ != %@", NSStringFromRect(currRect),NSStringFromRect(saveRect	));
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
		TitleView *stv = [titles objectForKey:rptName];
		NSRect rect = rects[i-1];
		
		if (data && control == nil){
			[[busy view] removeFromSuperview];
			
			[busys removeObjectForKey:rptName];
			NSLog(@"removing busy %@", busy);
			[busy release];
			busy = nil;
		}
		// don't add a view if there is no data 
		if ([data count] > 0 && control == nil){
			// create table view control/box and add it to the view
			svc = [self getViewForInstance:rpt width:viewWidth rows:setting.height];
			[svcs setObject: svc forKey:rptName];
			[svc setData: data];
			[[svc view] setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
			NSBox *box = [[BGHUDBox alloc] initWithFrame:winRect];
			[controls setObject:box forKey:rptName];
			NSSize margins; margins.height = 0; margins.width = 0;
			[box setContentViewMargins:margins];
			[box setContentView:svc.view];
			NSString *titleLabel = ([data count] == 0) 
				? [setting.label stringByAppendingFormat:@" [empty]"] 
				: setting.label;
			NSDictionary *attrs = [NSDictionary dictionaryWithObject:[NSColor whiteColor] 
															  forKey:NSForegroundColorAttributeName];
			NSString *titleStr = [[NSAttributedString alloc]initWithString:titleLabel 
																attributes:attrs];
			[box setTitle:titleStr];
			[box setTitlePosition:NSAboveTop];
			[box setBoxType:NSBoxSecondary];
			[view addSubview:box];
			control = box;
		}
		if (svc) {
			[view addSubview:svc.view];
			[control removeFromSuperview];
			[control setHidden:NO];
			[[svc view] setHidden:NO];
			//	[svc.table setHidden:NO];
			NSRect boxFrame;
			
			lineHeight = [svc.table rowHeight];
			//NSLog(@"before totalheight = %f for %@", totalHeight, [rpt name]);
			boxFrame.origin.y = totalHeight;
			boxFrame.origin.x = 21;
			boxFrame.size.width = winRect.size.width - 24;
			boxFrame.size.height = [svc actualHeight] + 5; //(lineHeight * 2);
			
			NSRect contentFrame = boxFrame;
			contentFrame.size.height = [svc actualHeight];

			[svc.view setFrame:contentFrame];
			rects[i-1] = contentFrame;
			[svc.view setNeedsDisplay:YES];
				
	
			NSRect stvFrame = boxFrame;
			stvFrame.origin.x = 5;
			stvFrame.size.width = 21;
			stvFrame.size.height = [svc actualHeight];
			if (!stv) {
				stv = [[TitleView alloc]initWithFrame:stvFrame];
				[stv setAutoresizingMask:NSViewHeightSizable];

				[stv setAltImage:[ctx iconImageForModule:rpt]];
				[titles setObject:stv forKey: rptName];
				NSFont *font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
				[stv setFont:font];
				[stv setTitleStr:setting.label];
		
				[view addSubview:stv];
			}
			[stv setFrame:stvFrame];

			totalHeight += boxFrame.size.height;			
		}
		
		if (data == nil && busy == nil)
		{
			// create busy control and add it to the view
			//NSLog(@"creating busy for %@", rptName);
			busy = [[HUDBusy alloc]initWithNibName:@"HUDBusyView" bundle:[NSBundle mainBundle]];
			NSLog(@"create new busy");
			[view addSubview:[busy view]];
			[busy setReporter:rpt];
			[busy setCaller:self];
			[[busy label] setStringValue:[setting label]]; 
			[busys setObject:busy forKey:rptName];
			[busy refresh:useCache];
		}
		if (busy) {
			[[busy view] setHidden:NO];
			NSRect busyRect = [[busy view] frame];
			busyRect.origin.y = totalHeight;
			busyRect.origin.x = 5;
			busyRect.size.width = winRect.size.width - 10;
			if (NSEqualRects(rect,busyRect) == NO || needsFrameChange) {
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
	
	NSRect tvFrame = NSMakeRect(5.0,totalHeight, viewWidth - 10.0, 14.0);
	if (!currentTaskView)
	{
		currentTaskView = [[TaskView alloc]initWithFrame:tvFrame];
		[currentTaskView setAutoresizingMask:NSViewNotSizable];
		[currentTaskView setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
		[currentTaskView setTitleStr:@"No active task set"];
		NSTimeInterval goal = [totalsManager calcGoal];
		NSTimeInterval work = [totalsManager workToday];
		NSString *workStr = [Utility durationStrFor:work];
		[currentTaskView setRatio: -1.0];
		if (goal > 0.0){
			[currentTaskView setRatio: work / goal];
		}
		[currentTaskView setTimeStr:workStr];
		if (ctx.currentTask && [ctx.currentTask objectForKey:@"name"]){
			[currentTaskView setTitleStr:[ctx.currentTask objectForKey:@"name"]];
		}
		[view addSubview:currentTaskView];
	}
	[currentTaskView setFrame:tvFrame];
	
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
	[datas setObject:array forKey:[rpt name]];
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

@implementation TaskView

@synthesize font, titleStr, saveFrame, timeStr, ratio;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		saveFrame = frame;
    }
    return self;
}

- (CGFloat) calcHueForRatio: (CGFloat) inRatio
{
	/** at zero we should be red (90) and at 100 we should be at orange (60) **/
	CGFloat start = 0.0;
	CGFloat end = 240.0;
	CGFloat range = end - start;
	CGFloat dist = inRatio * range;
	return dist / 360.0;
}

- (void)drawRect:(NSRect)dirtyRect {
	// 1 label
	NSColor *labelColor = [NSColor colorWithDeviceHue:0.0 saturation:0.0 brightness:0.80 alpha:1.0];
	NSDictionary *labelAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   labelColor, NSForegroundColorAttributeName,
						   font, NSFontAttributeName,
						   nil];
	NSDictionary *valueAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSColor whiteColor], NSForegroundColorAttributeName,
								font, NSFontAttributeName,
								nil];
	NSBezierPath *path = [NSBezierPath bezierPath];
	NSColor *patchColor = [[self window] backgroundColor];
	if (ratio >= 0.0){
		CGFloat hue = [self calcHueForRatio: ratio];
		patchColor = [NSColor colorWithDeviceHue:hue saturation:0.66 brightness:0.80 alpha:1];
	}
	CGFloat rPos = saveFrame.size.width - 78.0;
	[patchColor set];
	[path appendBezierPathWithRect:NSMakeRect(rPos+45, -1.0, 48.0, 16.0)];
	[path fill];
	[@"Tracking:" drawAtPoint:NSMakePoint(10, 0) withAttributes:labelAttrs];
	[titleStr drawAtPoint:NSMakePoint(65.0, 0) withAttributes:valueAttrs];
	[@"Worked:" drawAtPoint:NSMakePoint(rPos, 0) withAttributes:labelAttrs];
	[timeStr drawAtPoint:NSMakePoint(rPos+45, 0) withAttributes:valueAttrs];
	
}
@end

@implementation TitleView
@synthesize font, titleStr, saveFrame, altImage;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		saveFrame = frame;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[self setToolTip:titleStr];
	if (saveFrame.size.height < 40.0){
		NSRect rect = saveFrame;
		NSImageView *iView = [[NSImageView alloc]initWithFrame:NSMakeRect(0, 0, rect.size.width-7, rect.size.width-7)];
		[self addSubview:iView];
		[altImage setSize:NSMakeSize(14, 14)];
		[iView setImage:altImage];
	//	NSImageRep *rep = [altImage bestRepresentationForRect:rect context:nil hints:nil];
	//	rect.size.height = rect.size.width;
	//	[altImage drawRepresentation:rep inRect:rect];
		return;
	}
	NSAffineTransform *xform = [[NSAffineTransform alloc] init];
	
	[xform translateXBy: 14.0 yBy: 0.0];
	[xform rotateByDegrees: 90.0];
	[xform concat]; 
	
	NSColor *labelColor = [NSColor colorWithDeviceHue:0.0 saturation:0.0 brightness:0.80 alpha:1.0];
	NSDictionary *labelAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
								labelColor, NSForegroundColorAttributeName,
								font, NSFontAttributeName,
								nil];
	NSRect rect = [titleStr boundingRectWithSize:saveFrame.size 
										 options:0 
									  attributes:labelAttrs];
	CGFloat shift = (saveFrame.size.height - rect.size.width) / 2;
	
	NSPoint newPt;
	newPt.x = shift;
	newPt.y = 0;
	[titleStr drawAtPoint:newPt withAttributes:labelAttrs];
}

@end