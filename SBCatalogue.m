//
//  SBCatalogue.m
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "SBCatalogue.h"
#import "SBSong.h"
#import "SBLongStringVT.h"

static SBCatalogue *singleton;

@implementation SBCatalogue

+ (void)initialize {
	[NSValueTransformer setValueTransformer: [[[SBLongStringVT alloc] init] autorelease]
									forName: @"SBLongStringVT"];
}

+ (SBCatalogue *)sharedCatalogue {
	if(!singleton) 
		singleton = [[SBCatalogue alloc] init];
	return singleton;
}

- (id)init {
	self = [super init];
	if(self) {
		[self setSongToPathMapping: [NSMutableDictionary dictionary]];
		[self setSongs: [NSMutableArray array]];
		[self loadCatalogue];
		
		[[NSNotificationCenter defaultCenter] addObserver: self 
												 selector: @selector(reloadOnNotify:)
													 name: @"SongSaved"
												   object: nil];
	}
	return self;
}

// =========================================================== 
//  - dealloc:
// =========================================================== 
- (void)dealloc {
    [songs release];
    [super dealloc];
}

- (void)loadCatalogue {
	NSString *rootPath = [[NSUserDefaults standardUserDefaults] objectForKey: @"SourceDirectoryPath"];
	if(!rootPath)
		rootPath = [@"~/Library/Application Support/SongBase/" stringByExpandingTildeInPath];
	
	if([[NSFileManager defaultManager] fileExistsAtPath: rootPath]) {
		NSString *file;
		NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath: rootPath];
		while (file = [enumerator nextObject]) {
			if ([[file pathExtension] isEqualToString:@"sbsong"]) {
				NSString *fullPath = [NSString stringWithFormat: @"%@/%@", rootPath, file];
				SBSong *song = [[SBSong alloc] initWithContentsOfFile: fullPath];
				if(song) {
					[[self mutableArrayValueForKey: @"songs"] addObject: song];
					[songToPathMapping setObject: fullPath forKey: [song uid]];
				}
				[song release];
			}
		}
	}
	else {
		NSRunAlertPanel(@"Missing Library",
						[NSString stringWithFormat: @"The library path %@ cannot be found.", rootPath],
						@"OK", nil, nil);
	}
}

- (void)reload {
	NSLog(@"Reloading...");
	[self setSongs: [NSMutableArray array]];
	[self loadCatalogue];
}

- (void)reloadOnNotify: (NSNotification *)note {
	NSLog(@"Reloading catalogue because song was saved");
	[self reload];
}

- (NSString *)pathForSong: (SBSong *)song {
	return [songToPathMapping objectForKey: [song uid]];
}

- (void)writeIndexToFile:(NSString *)file atomically: (BOOL)flag {
	NSFont *boldFont = [NSFont boldSystemFontOfSize: 10.0];
	NSFont *regularFont = [NSFont systemFontOfSize: 10.0];
	
	NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
	NSArray *sortedArray = [[self songs] sortedArrayUsingSelector: @selector(compare:)];
	NSEnumerator *en = [sortedArray objectEnumerator];
	SBSong *song;
	int i = 1;
	while(song = [en nextObject]) {
		NSString *data = [NSString stringWithFormat: @"%d: %@", i, [song title]];
		i++;
		NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString: data];

		[title setAttributes: [NSDictionary dictionaryWithObject: boldFont forKey: NSFontAttributeName] 
					   range: NSMakeRange(0, [title length])];
		[attrStr appendAttributedString: title];
		
		[attrStr appendAttributedString: [[[NSAttributedString alloc] initWithString: @"\n"] autorelease]];
	}
	
	NSData *rtf = [attrStr RTFFromRange: NSMakeRange(0, [attrStr length])
					 documentAttributes: nil];
	[rtf writeToFile: file atomically: YES];
}

// =========================================================== 
// - songs:
// =========================================================== 
- (NSMutableArray *)songs {
    return songs; 
}

// =========================================================== 
// - setSongs:
// =========================================================== 
- (void)setSongs:(NSMutableArray *)aSongs {
    if (songs != aSongs) {
        [aSongs retain];
        [songs release];
        songs = aSongs;
    }
}


// =========================================================== 
// - songToPathMapping:
// =========================================================== 
- (NSMutableDictionary *)songToPathMapping {
    return songToPathMapping; 
}

// =========================================================== 
// - setSongToPathMapping:
// =========================================================== 
- (void)setSongToPathMapping:(NSMutableDictionary *)aSongToPathMapping {
    if (songToPathMapping != aSongToPathMapping) {
        [aSongToPathMapping retain];
        [songToPathMapping release];
        songToPathMapping = aSongToPathMapping;
    }
}
@end
