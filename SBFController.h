//
//  SBFController.h
//  SongBase
//
//  Created by Fraser Speirs on 13/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBFController : NSArrayController {
	NSString *searchTerm;
}
- (IBAction)search: (id)sender;
- (NSString *)searchTerm;
- (void)setSearchTerm:(NSString *)aSearchTerm;

@end
