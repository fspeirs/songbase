//
//  SBFController.m
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "SBFController.h"

@interface NSString (CharSetHack)
- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set;
@end
@interface NSMutableString (CharSetHack)
- (void)removeCharactersInSet:(NSCharacterSet *)set;
@end

@implementation SBFController
- (NSArray *)arrangeObjects:(NSArray *)objects
{
    NSMutableArray *matchedObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    if(searchTerm == nil || [searchTerm length] == 0) {
		[matchedObjects addObjectsFromArray: objects];
	}
	else {
		NSString *lowerSearch = [[[self searchTerm] lowercaseString] stringByRemovingCharactersFromSet: [NSCharacterSet punctuationCharacterSet]];
		
		NSEnumerator *oEnum = [objects objectEnumerator];
		id item;	
		while (item = [oEnum nextObject]) {
			
			NSString *title = [[item valueForKeyPath: @"title"] lowercaseString];
			NSString *copyright = [[item valueForKeyPath: @"copyright"] lowercaseString];
			
			// Search these from shortest to longest, in the hope that we can go 
			// faster by not searching content until we have to
			if(title != nil && [title rangeOfString: lowerSearch].location != NSNotFound) {
				[matchedObjects addObject: item];
			}
			else if(copyright != nil && [copyright rangeOfString: lowerSearch].location != NSNotFound) {
				[matchedObjects addObject: item];
			}
			else {
				NSAttributedString *content = [[NSAttributedString alloc] initWithRTF: [item valueForKeyPath: @"encodedRTFD"]
																	documentAttributes: nil];
				NSString *contentString = [[[content string] lowercaseString] stringByRemovingCharactersFromSet: [NSCharacterSet punctuationCharacterSet]];
				if ([contentString rangeOfString:lowerSearch].location != NSNotFound) {
					[matchedObjects addObject: item];
				}
			}
		}
	}
    return [super arrangeObjects:matchedObjects];
}

- (IBAction)search: (id)sender {
	[self setSearchTerm: [sender stringValue]];
	[self rearrangeObjects];
}

// =========================================================== 
// - searchTerm:
// =========================================================== 
- (NSString *)searchTerm {
    return searchTerm; 
}

// =========================================================== 
// - setSearchTerm:
// =========================================================== 
- (void)setSearchTerm:(NSString *)aSearchTerm {
    if (searchTerm != aSearchTerm) {
        [aSearchTerm retain];
        [searchTerm release];
        searchTerm = aSearchTerm;
    }
}
@end

@implementation NSString (CharSetHack)
- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set
{
    NSMutableString	*temp;

    if([self rangeOfCharacterFromSet:set options:NSLiteralSearch].length == 0)
        return self;
    temp = [[self mutableCopyWithZone:[self zone]] autorelease];
    [temp removeCharactersInSet:set];

    return temp;
}
@end

@implementation NSMutableString (CharSetHack)
- (void)removeCharactersInSet:(NSCharacterSet *)set
{
    NSRange			matchRange, searchRange, replaceRange;
    unsigned int    length;

    length = [self length];
    matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:NSMakeRange(0, length)];
    while(matchRange.length > 0)
        {
        replaceRange = matchRange;
        searchRange.location = NSMaxRange(replaceRange);
        searchRange.length = length - searchRange.location;
        for(;;)
            {
            matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:searchRange];
            if((matchRange.length == 0) || (matchRange.location != searchRange.location))
                break;
            replaceRange.length += matchRange.length;
            searchRange.length -= matchRange.length;
            searchRange.location += matchRange.length;
            }
        [self deleteCharactersInRange:replaceRange];
        matchRange.location -= replaceRange.length;
        length -= replaceRange.length;
        }
}

@end