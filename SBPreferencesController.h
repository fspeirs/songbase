//
//  SBPreferencesController.h
//  SongBase
//
//  Created by Fraser Speirs on 14/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OAFontView;

@interface SBPreferencesController : NSWindowController {
	IBOutlet OAFontView *fontView;
	IBOutlet NSUserDefaultsController *defsController;
}

- (IBAction)chooseLibraryPath:(id)sender;

@end
