//
//  MyDocument.m
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright __MyCompanyName__ 2004 . All rights reserved.
//

#import "MyDocument.h"
#import "SBSong.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		[self setSong: [[[SBSong alloc] init] autorelease]];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (BOOL)writeToFile: (NSString *)file ofType: (NSString *)aType {
	BOOL success = [[self song] writeToFile: file atomically: YES];
	if(success) {
		[[NSNotificationCenter defaultCenter] postNotificationName: @"SongSaved"
															object: nil];
	}
	return success;
}

- (BOOL)readFromFile: (NSString *)file ofType: (NSString *)type {
	[self setSong: [[[SBSong alloc] initWithContentsOfFile: file] autorelease]];
	
	return [self song] != nil;
}


// =========================================================== 
// - song:
// =========================================================== 
- (SBSong *)song {
    return song; 
}

// =========================================================== 
// - setSong:
// =========================================================== 
- (void)setSong:(SBSong *)aSong {
    if (song != aSong) {
        [aSong retain];
        [song release];
        song = aSong;
    }
}
@end
