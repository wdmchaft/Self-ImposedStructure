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
#import "SummaryViewController.h"
#import "HUDCellController.h"
#import "NSButton+TextColor.h"
#import "MyTheme.h"

@implementation SummaryHUDControl
@synthesize mainControl;

@synthesize framePos;
@synthesize saveRect;
@synthesize totalsManager;
@synthesize splitter;
@synthesize header;
@synthesize datas;
@synthesize busys;
@synthesize cells;
@synthesize doingBuild;
@synthesize renderedViews;
@synthesize viewsHeight;
@synthesize useCache;
@synthesize taskField;
@synthesize timeField;

- (void) awakeFromNib
{
}

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
	BGThemeManager *mgr = [BGThemeManager keyedManager];
	[mgr setTheme:[MyTheme new] forKey:@"myTheme"];
}

- (id) initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	if (self){
		framePos = [window stringWithSavedFrame];
		[window setAllowsToolTipsWhenApplicationIsInactive:YES];
		busys = [NSMutableDictionary dictionaryWithCapacity:5];
		datas = [NSMutableDictionary dictionaryWithCapacity:5];
		cells = [NSMutableDictionary dictionaryWithCapacity:5];
		NSView *v = [[self window] contentView];
		NSRect vFrame = [v frame];
		NSRect frame = [v frame];
		frame.origin.y = 15;
		frame.size.height = vFrame.size.height - 29;
		doingBuild = YES;
	}
	return self;
}

- (void) windowDidResize:(NSNotification *)notification	
{
	NSRect frame = [[[self window] contentView] frame];
	[splitter setFrame:NSMakeRect(0, 20, frame.size.width, frame.size.height - 48)];
}

- (HUDCellController*) getCellForSetting: (HUDSetting*) setting
								   parent: (NSSplitView*) pView 
								  oldView: (NSView*) view
									 data: (NSMutableArray*) dataArray
{
	id<Reporter> inst = [setting reporter];
	int nRows = [setting height];
	
	NSString *rptNib;
	HUDCellController *hcc = [[HUDCellController alloc]initWithNibName:@"HUDCell" bundle:nil];
	if (hcc){
		SummaryViewController *svc = nil;
		CGFloat vWidth = [pView bounds].size.width;
		switch (inst.category) {
			case CATEGORY_EMAIL:
				rptNib = @"MailTableView";
				svc = [[SummaryMailViewController alloc] initWithNibName: rptNib 
																  bundle:[NSBundle mainBundle]];
				break;
			case CATEGORY_TASKS:
				rptNib = @"TaskTableView";
				svc = [[SummaryTaskViewController alloc] initWithNibName: rptNib 
																  bundle:[NSBundle mainBundle] ];
				break;
			case CATEGORY_EVENTS:
				rptNib = @"EventTableView";
				svc = [[SummaryEventViewController alloc] initWithNibName: rptNib 
																   bundle:[NSBundle mainBundle] ];
				break;
			default:
				break;	
		}
		[svc setReporter:inst];
		[svc setWidth:vWidth];
		[svc setMaxLines:nRows];
		[svc setData:dataArray];
		[svc setCaller:self];
		[hcc setDataController:svc];
		NSView *hView = [hcc view];
		[hView setFrameSize:NSMakeSize([hView frame].size.width,(nRows * 16) - 1)];
		if (view){
			[pView replaceSubview:view with: hView];
			NSLog(@"replaced cell with hView: %@",hView);
		}
		else {
			[pView addSubview:hView];
			NSLog(@"added cell hView: %@",hView);
		}
		
		NSView *hcView = [hcc dataView];
		[[hcc titleView]setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
		[[hcc view] replaceSubview:hcView with:[svc view]];	
		
		NSUInteger lineHeight = [[svc table] rowHeight];
		[[svc view] setFrameOrigin:NSMakePoint(20,0)];
		[[svc view] setFrameSize: NSMakeSize([hView frame].size.width - 20, (nRows * lineHeight))];
		[[svc view] setHidden:NO];
		HUDCellTitleView *tView = [hcc titleView];
		[tView setTitle:[setting label]];
		[tView setFrameOrigin:NSMakePoint(3, 0)]; 
		[[hcc view] setHidden:NO];
		
		return hcc;
	}
	return nil;
}

- (void) viewSized: (NSView*) view reporter: (id<Reporter>) rpt data: (NSArray*) array
{
	[datas setObject:array forKey:[rpt name]];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	return !doingBuild;
}

- (CGFloat)splitView  :(NSSplitView *)	splitView 
constrainMinCoordinate:(CGFloat)		proposedMin 
		   ofSubviewAt:(NSInteger)		dividerIndex
{
	CGFloat min = 0.0;
	if (doingBuild){
		Context *ctx = [Context sharedContext];
		NSArray *settings = [[ctx hudSettings] allEnabled];
		for (NSUInteger s = 0; s <= dividerIndex;s++){
			HUDSetting *st = [settings objectAtIndex:s];
			min += ([st height] * 16) - 1;
			min += (s > 0) ? [splitView dividerThickness] : 0;
		}
	}
	return min;
}


/*** 
 the display is just a stack of nsboxes containing tables.  Each table has a maximum size, but if there are fewer 
 rows it could be smaller. and if the table is empty then it will not display nor will its surrounding box.
 buildDisplay will launch the summaryviewcontrollers for each table.  Each time the controllers either get an initial response or are complete the refreshDisplay method is called.
 ***/

- (void) buildDisplay 
{
	[buildTimer invalidate];
	buildTimer = nil;
	NSRect rect = [[self window] frame];
	Context *ctx =[Context sharedContext];
	NSArray *settings = [[ctx hudSettings] allEnabled];
	NSUInteger currentViewCount = 0;
	// precalc the height of the splitter
	viewsHeight = 0;
	NSUInteger hccCount = 0;
	for (HUDSetting *setting in settings)
	{
		NSMutableArray *rptData = [datas objectForKey:[[setting reporter]name]];
		HUDCellController *hcc  = [cells objectForKey:[[setting reporter]name]];
		HUDBusy *busy			= [busys objectForKey:[[setting reporter]name]];
		
		if (rptData == nil && busy == nil){
			viewsHeight += 28;
			currentViewCount++;
		}
		else if (rptData && [rptData count] == 0){
		}
		else if (rptData && [rptData count] && hcc == nil){
			viewsHeight += ([setting height] * 16) - 1;
			currentViewCount++;
		}
		else if (hcc){
			hccCount++;
			viewsHeight += ([setting height] * 16) - 1;
			currentViewCount++;
		}
	}
	renderedViews = currentViewCount;
	CGFloat currHeight = viewsHeight;
	currHeight += ((renderedViews - 1) * [splitter dividerThickness]);
	
	[splitter setFrameSize: NSMakeSize([splitter frame].size.width, currHeight)];
	//	[splitter adjustSubviews];
	[splitter setFrameOrigin:NSMakePoint(0, 20)];
	NSSize sz = [splitter frame].size;
	sz.height +=48;
	
	[[self window] setContentSize: sz];
	NSMutableArray *orderedViews = [NSMutableArray arrayWithCapacity:[settings count]];
	for (HUDSetting *setting in settings)
	{
		NSMutableArray *rptData = [datas objectForKey:[[setting reporter]name]];
		HUDCellController *hcc  = [cells objectForKey:[[setting reporter]name]];
		HUDBusy *busy			= [busys objectForKey:[[setting reporter]name]];
		
		if (hcc){
			[[hcc view] setFrameOrigin: NSMakePoint(0, 0)];
			NSSize scrollSz, hccSz;
			scrollSz = hccSz = NSMakeSize([splitter frame].size.width, ([setting height] * 16) - 1);
			[[hcc view] setFrameSize:hccSz ];
			NSScrollView *scroll  = (NSScrollView*) [[hcc dataController] view];
			[scroll setFrameOrigin: NSMakePoint(20, 0)];
			scrollSz.width -= 20;
			[scroll setFrameSize:scrollSz ];
			[orderedViews addObject:[hcc view]];
		}
		else if (rptData && [rptData count] && hcc == nil){
			HUDCellController *hcc = [self getCellForSetting:setting 
													   parent:splitter 
													  oldView:[busy view]
														 data:rptData];
			
			[[[hcc dataController] table] reloadData];
			[cells setObject:hcc forKey:[[setting reporter]name]];
			[orderedViews addObject :[hcc view]];
			if (busy) {
				[[busy view] removeFromSuperview];
				[busys removeObjectForKey:[[setting reporter]name]];
			}
		}
		else if (rptData && [rptData count] == 0){
			if (busy){
				[[busy view] removeFromSuperview];
				[busys removeObjectForKey:[[setting reporter] name]];
				busy = nil;
			}
		}		
		else if (busy){
			[orderedViews addObject:[busy view]];
		}
		
		else if (rptData == nil && busy == nil){
			HUDBusy *busy = [[HUDBusy alloc] initWithNibName:@"HUDBusyView" bundle:nil];
			[busys setObject:busy forKey:[[setting reporter] name]];
			NSView *bv = [busy view];
			[bv setFrame:NSMakeRect(0, 0, rect.size.width, 28)];
			[splitter addSubview:bv]; 			
			[[busy label] setStringValue:[[setting reporter]name]];
			[busy setReporter:[setting reporter]];
			[busy setCaller:self];
			[busys setObject:busy forKey:[[setting reporter] name]];
			
			[busy refresh:NO];	
			[orderedViews addObject:[busy view]];
			buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(buildDisplay) userInfo:nil repeats:NO];
		} 
	}			
	
	[splitter setSubviews:orderedViews];
	
	if (hccCount == renderedViews && [datas count] == [settings count]){
		doingBuild = NO;
	} else {
		buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(buildDisplay) userInfo:nil repeats:NO];
	}
}

- (void) showSwitchActivity: (id) sender
{
	[mainControl clickSwitchActivity:mainControl];
}

- (void) setupHeader
{
	Context *ctx = [Context sharedContext];

	NSString *task = @"No active task set";
	NSTimeInterval goal = [totalsManager calcGoal];
	NSTimeInterval work = [totalsManager workToday];
	NSString *workStr = [Utility durationStrFor:work];
	CGFloat ratio = -1.0;
	if (goal > 0.0){
		ratio = work / goal;
	}
	[timeField setStringValue: workStr];
	NSString *currTask = [[ctx currentTask] objectForKey:@"name"];
	NSColor *clr = [NSColor yellowColor];
	if (currTask){
		task =[[ctx currentTask] objectForKey:@"name"];
		clr = [NSColor whiteColor];
	}
	[taskField setTitle:task];
	[taskField setTextColor:clr];
}

- (void) taskNameChanged: (NSString*) task 
{
	NSColor *clr = [NSColor whiteColor];
	if (!task){
		task = @"No active task set";
		clr = [NSColor yellowColor];
	}
	[taskField setTitle:task];
	[taskField setTextColor:clr];
}

- (void) taskChanged: (NSNotification*) msg
{
	[self taskNameChanged:[[msg userInfo] objectForKey:@"name"]];
}

- (void) dataChanged: (NSNotification*) msg
{
	NSString *modName = [[msg userInfo]objectForKey:@"module"];
	NSString *taskName = [[msg userInfo]objectForKey:@"name"];
	NSMutableArray *data = [datas objectForKey:modName];
	[data removeAllObjects];
	[datas removeObjectForKey:modName];
	data = nil;
	
	[busys removeObjectForKey:modName];
	HUDCellController *hcc = [cells objectForKey:modName];
	[[hcc view] removeFromSuperview];
	[cells removeObjectForKey:modName];
	NSString *currTask =  [[Context sharedContext].currentTask objectForKey:@"name"];
	if (currTask && taskName && [currTask isEqualToString:taskName]){
		[self taskNameChanged:nil];
	}

	buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(buildDisplay) userInfo:nil repeats:NO];
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
	
	NSArray *settings = [[ctx hudSettings] allEnabled];
	
	NSRect rect = [[[self window] contentView] bounds];
	rect.size.height = 0;
	[splitter setFrameSize:rect.size];
	
	for (HUDSetting *setting in settings){
		HUDBusy *busy = [[HUDBusy alloc] initWithNibName:@"HUDBusyView" bundle:nil];
		NSView *bv = [busy view];
		[bv setFrame:NSMakeRect(0, 0, rect.size.width, 28)];
		[splitter addSubview:bv];
		[[busy label] setStringValue:[[setting reporter]name]];
		[busy setReporter:[setting reporter]];
		[busy setCaller:self];
		[busys setObject:busy forKey:[[setting reporter] name]];
		[busy refresh:NO];
	}
	
	[splitter setFrameOrigin:NSMakePoint(0, 20)];
	CGFloat splitHeight = 28 * [settings count];
	splitHeight += ( ([settings count] - 1) * [splitter dividerThickness]);
	[splitter setFrameSize: NSMakeSize([splitter frame].size.width, splitHeight)];
	//[splitter adjustSubviews];
	NSSize sz = [splitter frame].size;
	sz.height +=48;
	NSLog(@"showWindow size = %@", NSStringFromSize(sz));
	[[self window] setContentSize: sz];

	renderedViews = [settings count];
	viewsHeight = 28 * renderedViews;
	buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(buildDisplay) userInfo:nil repeats:YES];
	NSString *activeQueue =  [Queues queueNameFor:WPA_ACTIVEQUEUE fromBase:ctx.queueName];
	NSString *completeQueue =  [Queues queueNameFor:WPA_COMPLETEQUEUE fromBase:ctx.queueName];
	NSString *updateQueue =  [Queues queueNameFor:WPA_UPDATEQUEUE fromBase:ctx.queueName];
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(dataChanged:) name:completeQueue object:nil];
	[center addObserver:self selector:@selector(dataChanged:) name:updateQueue object:nil];
	[center addObserver:self selector:@selector(taskChanged:) name:activeQueue object:nil];
	useCache = YES;
	
	[self setupHeader];
}

- (void) windowDidLoad
{
	[super.window makeKeyAndOrderFront:nil];
	
}

- (void) windowWillClose:(NSNotification *)notification
{
	if (buildTimer){
		[buildTimer invalidate];
		buildTimer = nil;
	}
}

- (void)windowDidMove:(NSNotification *)aNotification
{
	framePos = [[self window] stringWithSavedFrame];
	//NSLog(@"setting framePos: %@", framePos);
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation MyButtonCell
- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	NSRect innerFrame = frame;
	innerFrame.size.height -= 2.0;
	innerFrame.size.width -= 3.0;
	innerFrame.origin.x += 1.5;
	innerFrame.origin.y	+= 1.0;
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:frame];
	[NSGraphicsContext saveGraphicsState];
	//	[path setLineJoinStyle:NSBevelLineJoinStyle];
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor: [NSColor blackColor]];
	[shadow setShadowBlurRadius: 2];
	[shadow setShadowOffset: NSMakeSize( 0, -1)];
	[shadow set];
	NSColor *darkClr = [NSColor colorWithDeviceRed: 0.141f green: 0.141f blue: 0.141f alpha: 0.5f];
	[darkClr set];
	[path setLineWidth:1.0];
	[path stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	
	//NSColor *borderClr = [NSColor colorWithDeviceRed: 0.749f green: 0.761f blue: 0.788f alpha: 1.0f];
	
	NSBezierPath *newPath = [NSBezierPath bezierPathWithRect:innerFrame];
	NSColor *borderClr = [NSColor whiteColor];
	[borderClr set];
	[newPath setLineWidth:1.0];
	[newPath stroke];
	
	NSGradient *grad= [[[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceRed: 0.324f green: 0.331f blue: 0.347f alpha: [controlView alphaValue]],
						(CGFloat)0, [NSColor colorWithDeviceRed: 0.245f green: 0.253f blue: 0.269f alpha: [controlView alphaValue]], .5f,
						[NSColor colorWithDeviceRed: 0.206f green: 0.214f blue: 0.233f alpha: [controlView alphaValue]], .5f,
						[NSColor colorWithDeviceRed: 0.139f green: 0.147f blue: 0.167f alpha: [controlView alphaValue]], 1.0f, nil] autorelease];
	
	[grad drawInBezierPath:newPath angle:90.0f];
	
}
- (NSRect) drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
	//NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
	//					   [NSColor whiteColor],NSForegroundColorAttributeName,
	//					   [NSFont systemFontOfSize:10],NSFontAttributeName,
	//					   nil ];
	//NSAttributedString *task = [[NSAttributedString alloc] initWithString:title.string attributes: attrs];
	
	[title drawInRect:frame];
	return frame;
}

@end



