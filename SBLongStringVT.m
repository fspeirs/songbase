//
//  SBLongStringVT.m
//  SongBase
//
//  Created by Fraser Speirs on 19/11/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "SBLongStringVT.h"

@implementation SBLongStringVT

+ (Class)transformedValueClass { return [NSAttributedString self]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
	if(value) {
		return [NSString stringWithFormat: @"%@\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", value];
	}

	return nil;
}

/* Optionally implement this
- (id)reverseTransformedValue:(id)value {

}
*/

@end
