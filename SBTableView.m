//
//  SBTableView.m
//  SongBase
//
//  Created by Fraser Speirs on 14/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "SBTableView.h"


@implementation SBTableView
- (void)keyDown: (NSEvent *)theEvent {

	if([theEvent type] == NSKeyDown && [[theEvent characters] characterAtIndex: 0] == 13) {
		[self doCommandBySelector: @selector(showSong:)];
	}
	else {
		[super keyDown: theEvent];
	}
}
@end
