//
//  SBSong.m
//  Songbase 2
//
//  Created by Fraser Speirs on 23/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SBSong.h"


@implementation SBSong
- (void)awakeFromInsert {
	[super awakeFromInsert];
	    
	[self setValue: [NSDate date] forKey: @"dateAdded"];
}

- (NSDictionary *)propertyListRepresentation {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NSEnumerator *keys = [[NSArray arrayWithObjects: @"copyright", @"dateAdded", @"lastPlayed", @"lyrics", @"playcount", @"songKey", @"title", nil] objectEnumerator];
	
	NSString *key;
	while(key = [keys nextObject]) {
		if([self valueForKey: key] != nil) {
			[dict setObject: [self valueForKey: key]
					 forKey: key];
		}
	}
	
	return dict;	
}

- (void)configureFromPropertyListRepresentation:(NSDictionary *)dict {
	NSEnumerator *keys = [[NSArray arrayWithObjects: @"copyright", @"dateAdded", @"lastPlayed", @"lyrics", @"playcount", @"songKey", @"title", nil] objectEnumerator];
	
	NSString *key;
	while(key = [keys nextObject]) {
		[self setValue: [dict objectForKey: key]
				forKey: key];
	}
	
}
@end
