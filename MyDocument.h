//
//  MyDocument.h
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright __MyCompanyName__ 2004 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class SBSong;

@interface MyDocument : NSDocument
{
	SBSong *song;
}

- (SBSong *)song;
- (void)setSong:(SBSong *)aSong;

@end
