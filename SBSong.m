//
//  SBSong.m
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "SBSong.h"


@implementation SBSong
- (id)init {
	self = [super init];
	if(self) {
		CFUUIDRef       myUUID;
		CFStringRef     myUUIDString;
		myUUID = CFUUIDCreate(kCFAllocatorDefault);
		myUUIDString = CFUUIDCreateString(kCFAllocatorDefault, myUUID);
		
		[self setUid: (NSString *)myUUIDString];
		[self setCopyright: @""];
		[self setTitle: @"New Song"];
		[self setEncodedRTFD: [NSMutableData data]];
	}
	return self;
}

// =========================================================== 
//  - dealloc:
// =========================================================== 
- (void)dealloc {
    [title release];
    [copyright release];
    [encodedRTFD release];
	
    title = nil;
    copyright = nil;
    encodedRTFD = nil;
	
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	SBSong *newSong = [[SBSong allocWithZone:zone] init];
	[newSong setTitle: [[self title] copy]];
	[newSong setCopyright: [[self copyright] copy]];
	[newSong setEncodedRTFD: [NSMutableData dataWithBytes: [self encodedRTFD] length: [[self encodedRTFD] length]]];
	
	return [newSong autorelease];
}

- (NSComparisonResult)compare: (id) value {
	return [[self title] compare: [value title]];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if([self title])
		[dict setObject: [self title] forKey: @"title"];
	
	if([self copyright])
		[dict setObject: [self copyright] forKey: @"copyright"];
	
	if([self encodedRTFD]) {
		[dict setObject: [self encodedRTFD] forKey: @"body"];
	}
	
	return [dict writeToFile: path atomically: YES];
}

- (id)initWithContentsOfFile: (NSString *)file {
	self = [self init];
	if(self) {
		NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile: file];
		if(contents) {
			[self setTitle: [contents objectForKey:@"title"]];
			[self setCopyright: [contents objectForKey:@"copyright"]];
			
			// Convert this to mutable data
			NSData *bodyData = [contents objectForKey:@"body"];
			NSMutableData *mBodyData = [NSMutableData dataWithBytes: [bodyData bytes] length: [bodyData length]];
			[self setEncodedRTFD: mBodyData];
			
			return self;
		}
		[self release];
		return nil; // Failed to load
	}
	return self;
}

// =========================================================== 
// - title:
// =========================================================== 
- (NSString *)title {
    return title; 
}

// =========================================================== 
// - setTitle:
// =========================================================== 
- (void)setTitle:(NSString *)aTitle {
    if (title != aTitle) {
        [aTitle retain];
        [title release];
        title = aTitle;
    }
}

// =========================================================== 
// - copyright:
// =========================================================== 
- (NSString *)copyright {
    return copyright; 
}

// =========================================================== 
// - setCopyright:
// =========================================================== 
- (void)setCopyright:(NSString *)aCopyright {
    if (copyright != aCopyright) {
        [aCopyright retain];
        [copyright release];
        copyright = aCopyright;
    }
}

// =========================================================== 
// - encodedRTFD:
// =========================================================== 
- (NSMutableData *)encodedRTFD {
    return encodedRTFD; 
}

// =========================================================== 
// - setEncodedRTFD:
// =========================================================== 
- (void)setEncodedRTFD:(NSMutableData *)anEncodedRTFD {
    if (encodedRTFD != anEncodedRTFD) {
        [anEncodedRTFD retain];
        [encodedRTFD release];
        encodedRTFD = anEncodedRTFD;
    }
}


// =========================================================== 
// - uid:
// =========================================================== 
- (NSString *)uid {
    return uid; 
}

// =========================================================== 
// - setUid:
// =========================================================== 
- (void)setUid:(NSString *)anUid {
    if (uid != anUid) {
        [anUid retain];
        [uid release];
        uid = anUid;
    }
}
@end
