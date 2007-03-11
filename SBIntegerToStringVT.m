//
//  SBIntegerToStringVT.m
//  Songbase 2
//
//  Created by Fraser Speirs on 11/03/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SBIntegerToStringVT.h"


@implementation SBIntegerToStringVT
+ (Class)transformedValueClass { return [NSString self]; }
+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(id)value {
	if(value) {
		return [NSString stringWithFormat: @"%d", [value intValue]];
	}

	return nil;
}

/* Optionally implement this */
- (id)reverseTransformedValue:(id)value {
	return [NSNumber numberWithInt: [value intValue]];
}
@end
