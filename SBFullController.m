#import "SBFullController.h"
#import "SBFSWindow.h"
#import "SBLongStringVT.h"

@implementation SBFullController
+ (void)initialize {
	SBLongStringVT *vt = [[SBLongStringVT alloc] init];
	
	[NSValueTransformer setValueTransformer: [vt autorelease]
									forName: @"SBLongStringVT"];
}

- (id)init {
	self = [super init];
	if(self) {
        blackView = [[NSView alloc] init];
        blackView.wantsLayer = YES;
        blackView.layer.backgroundColor = [NSColor.blackColor CGColor];
        
        [[NSBundle mainBundle] loadNibNamed: @"FullScreenWindow" owner: self topLevelObjects: &topLevelWindowObjects];
		NSWindow *win = [[SBFSWindow alloc] initWithContentRect: NSMakeRect(20,20,400,800)//screenRect
													  styleMask: NSWindowStyleMaskBorderless
														backing: NSBackingStoreBuffered
														  defer: NO
														 screen: [NSScreen mainScreen]];
		[win setDelegate: (id)self];
		[win setContentView: [mainView retain]];
		[win setLevel:CGShieldingWindowLevel()];
		[self setWindow: win];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(showNewSong:)
													 name: @"SongSelected"
												   object: nil];
        
        

	}
	return self;
}

- (void)showWindow:(id)sender {
	NSScreen *displayScreen = [[NSScreen screens] objectAtIndex: 0];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey: @"PresentOnAlternateDisplay"] && 
	   [[NSScreen screens] count]>1)
	{
		displayScreen = [[NSScreen screens] objectAtIndex: 1];
	}
	
	[[self window] setFrame: [displayScreen frame] display: YES];	
	
	[textView scrollRangeToVisible: NSMakeRange(0,1)];
	
	[super showWindow: sender];
}

- (void)showNewSong: (NSNotification *)note {
	[self setCurrentSong: [note object]];
	[self showWindow: self];
}

- (void)clearSongAndHideWindow {
	[self setCurrentSong: nil];
	[[self window] orderOut: self];
}

- (void)toggleBlackWindowState {
    if(self.window.contentView == mainView) {
        self.window.contentView = blackView;
    } else {
        self.window.contentView = mainView;
    }
}

// =========================================================== 
// - currentSong:
// =========================================================== 
- (id)currentSong {
    return currentSong; 
}

// =========================================================== 
// - setCurrentSong:
// =========================================================== 
- (void)setCurrentSong:(id)aCurrentSong {
    if (currentSong != aCurrentSong) {
        [aCurrentSong retain];
        [currentSong release];
        currentSong = aCurrentSong;
		[textView setNeedsDisplay: YES];
    }
}

@end
