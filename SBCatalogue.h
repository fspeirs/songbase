//
//  SBCatalogue.h
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBCatalogue : NSObject {
	NSMutableArray *songs;
	
	NSMutableDictionary *songToPathMapping;
}

+ (SBCatalogue *)sharedCatalogue;

- (void)loadCatalogue;
- (void)reload;

- (NSMutableArray *)songs;
- (void)setSongs:(NSMutableArray *)aSongs;
- (NSMutableDictionary *)songToPathMapping;
- (void)setSongToPathMapping:(NSMutableDictionary *)aSongToPathMapping;

- (void)writeIndexToFile:(NSString *)file atomically: (BOOL)flag;
@end
