//
//  SBFSWindow.m
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "SBFSWindow.h"


@implementation SBFSWindow
- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)sendEvent:(NSEvent *)theEvent {
	if([theEvent type] == NSKeyDown && [[theEvent characters] characterAtIndex: 0] == 27) {
		id del = [self delegate];
		if([del respondsToSelector: @selector(clearSongAndHideWindow)])
			[self doCommandBySelector: @selector(clearSongAndHideWindow)];
	}
	else {
		[super sendEvent: theEvent];
	}
}
@end
