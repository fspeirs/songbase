//
//  SBSong.h
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBSong : NSObject {
	NSString *title;
	NSString *copyright;
	NSMutableData *encodedRTFD;
	NSString *uid;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;

- (NSString *)title;
- (void)setTitle:(NSString *)aTitle;

- (NSString *)copyright;
- (void)setCopyright:(NSString *)aCopyright;

- (NSMutableData *)encodedRTFD;
- (void)setEncodedRTFD:(NSMutableData *)anEncodedRTFD;

- (NSString *)uid;
- (void)setUid:(NSString *)anUid;

@end
