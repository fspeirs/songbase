/* SBFullController */

#import <Cocoa/Cocoa.h>

@interface SBFullController : NSWindowController
{
	IBOutlet NSView *mainView;
	IBOutlet NSTextView *textView;
    NSView *blackView;
    NSArray *topLevelWindowObjects;
	id currentSong;
}

- (id)currentSong;
- (void)setCurrentSong:(id)aCurrentSong;
- (void)clearSongAndHideWindow;

// Toggles whether the window is completely covered with black
- (void)toggleBlackWindowState;
@end
