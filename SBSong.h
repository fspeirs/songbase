//
//  SBSong.h
//  Songbase 2
//
//  Created by Fraser Speirs on 23/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBSong : NSManagedObject {

}
- (NSDictionary *)propertyListRepresentation;
- (void)configureFromPropertyListRepresentation:(NSDictionary *)dict;
@end
