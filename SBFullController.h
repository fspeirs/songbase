/* SBFullController */

#import <Cocoa/Cocoa.h>

@class SBSong;

@interface SBFullController : NSWindowController
{
	SBSong *currentSong;
	IBOutlet NSView *mainView;
	IBOutlet NSTextView *textView;
}
- (SBSong *)currentSong;
- (void)setCurrentSong:(SBSong *)aCurrentSong;

@end
