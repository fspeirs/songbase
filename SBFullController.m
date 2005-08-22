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
		[NSBundle loadNibNamed: @"FullScreenWindow" owner: self];
		NSWindow *win = [[SBFSWindow alloc] initWithContentRect: NSMakeRect(20,20,400,800)//screenRect
													  styleMask: NSBorderlessWindowMask
														backing: NSBackingStoreBuffered
														  defer: NO
														 screen: [NSScreen mainScreen]];
		[win setDelegate: self];
		[win setContentView: mainView];
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
