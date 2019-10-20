/* SBFullController */

#import <Cocoa/Cocoa.h>

@interface SBFullController : NSWindowController
{
	IBOutlet NSView *mainView;
	IBOutlet NSTextView *textView;
    NSArray *topLevelWindowObjects;
	id currentSong;
}

- (id)currentSong;
- (void)setCurrentSong:(id)aCurrentSong;
- (void)clearSongAndHideWindow;
@end
