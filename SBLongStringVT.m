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
		NSDictionary *docProps;
		NSMutableAttributedString *originalString = [[NSMutableAttributedString alloc] initWithRTF: value
																				documentAttributes: &docProps];

	// Return the value as the kind declared in transformedValueClass
		NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithAttributedString: originalString];
		int i;
		NSAttributedString *ret =[[NSAttributedString alloc] initWithString: @"\n"];
		for(i=0; i < 30; i++)
			[attString appendAttributedString: ret];
		
		[ret release];
		[originalString release];
		[attString autorelease];
		
		// Now set some paragraph attributes
		NSFont *bigFont = [NSFont systemFontOfSize: 42.0];
		[attString addAttributes: [NSDictionary dictionaryWithObject: bigFont forKey: NSFontAttributeName]
						   range: NSMakeRange(0,[attString length])];
		
		return [attString RTFFromRange: NSMakeRange(0,[attString length]) 
					documentAttributes: nil];
	}

	return nil;
}

/* Optionally implement this
- (id)reverseTransformedValue:(id)value {

}
*/

@end
