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
	
	[self setValue: [NSCalendarDate date] forKey: @"dateAdded"];
}
@end
