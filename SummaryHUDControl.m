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

@implementation SummaryHUDControl
@synthesize mainControl;

@synthesize framePos;
@synthesize saveRect;
@synthesize currentTaskView;
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
	NSWindow *win = [self window];
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

- (HUDCellController*) getCellForInstance:  (id<Reporter>) inst 
								   parent: (NSSplitView*) pView 
									 rows: (int) nRows
								  oldView: (NSView*) view
									 data: (NSMutableArray*) dataArray
{
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
		[tView setTitle:[inst name]];
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
	NSLog(@"buildDisplay %d subviews", [[splitter subviews] count]);
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
	
	NSLog(@"buildDisplay size = %@", NSStringFromSize(sz));
	[[self window] setContentSize: sz];
	
	for (HUDSetting *setting in settings)
	{
		NSMutableArray *rptData = [datas objectForKey:[[setting reporter]name]];
		HUDCellController *hcc  = [cells objectForKey:[[setting reporter]name]];
		HUDBusy *busy			= [busys objectForKey:[[setting reporter]name]];
		
		if (rptData == nil && busy == nil){
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
			buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(buildDisplay) userInfo:nil repeats:YES];
		}
		if (rptData && [rptData count] == 0){
			[[busy view] removeFromSuperview];
		}
		if (rptData && [rptData count] && hcc == nil){
			HUDCellController *hcc = [self getCellForInstance:[setting reporter] 
													   parent:splitter 
														 rows:[setting height]
													  oldView:[busy view]
														 data:rptData];
			
			
			[[[hcc dataController] table] reloadData];
			[cells setObject:hcc forKey:[[setting reporter]name]];
		}
		else if (hcc){
			[[hcc view] setFrameOrigin: NSMakePoint(0, 0)];
			NSSize scrollSz, hccSz;
			scrollSz = hccSz = NSMakeSize([splitter frame].size.width, ([setting height] * 16) - 1);
			[[hcc view] setFrameSize:hccSz ];
			NSView *canary = [[hcc dataController] view];
			NSAssert([canary isKindOfClass:[NSScrollView class]],@"oops");
			NSScrollView *scroll  = (NSScrollView*) [[hcc dataController] view];
			[scroll setFrameOrigin: NSMakePoint(20, 0)];
			scrollSz.width -= 20;
			[scroll setFrameSize:scrollSz ];
			
		}
	}
	
	if (hccCount == renderedViews && [datas count] == [settings count]){
		NSLog(@"buildDisplay done building");
		[buildTimer invalidate];
		buildTimer = nil;
		doingBuild = NO;
	}
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
	if (ctx.currentTask && [ctx.currentTask objectForKey:@"name"]){
		task =[ctx.currentTask objectForKey:@"name"];
	}
	[taskField setStringValue:task];
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
	//	NSRect content = [[[self window] contentView] bounds]; 
	//	NSRect winRect = [[self window] frameRectForContentRect: content];
	//	[[self window] setFrame: winRect display:YES];
	renderedViews = [settings count];
	viewsHeight = 28 * renderedViews;
	buildTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(buildDisplay) userInfo:nil repeats:YES];
	NSString *updateQueue =  [Queues queueNameFor:WPA_UPDATEQUEUE fromBase:ctx.queueName];
	NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(dataChanged:) name:updateQueue object:nil];
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
