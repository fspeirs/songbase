//
//  SBFSWindow.m
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 Connected Flow. All rights reserved.
//

#import "SBFSWindow.h"


@implementation SBFSWindow
- (BOOL)canBecomeKeyWindow
{
    return YES;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)sendEvent:(NSEvent *)theEvent {
    if([theEvent type] == NSEventTypeKeyDown && [[theEvent characters] characterAtIndex: 0] == 27) {
		id del = [self delegate];
        if([del respondsToSelector: @selector(clearSongAndHideWindow)]) {
			[self doCommandBySelector: @selector(clearSongAndHideWindow)];
        }
	}
	else {
		[super sendEvent: theEvent];
	}
}

#pragma clang diagnostic pop
@end
