//
//  SBPreferencesController.m
//  SongBase
//
//  Created by Fraser Speirs on 14/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "SBPreferencesController.h"
#import "OAFontView.h"

@implementation SBPreferencesController
- (id)init {
	self = [super init];
	if(self) {
		[NSBundle loadNibNamed: @"Preferences" owner: self];
		
		[fontView addObserver: self
				   forKeyPath: @"font"
					  options: NSKeyValueObservingOptionNew
					  context: nil];
		
		NSUserDefaults *defs = [defsController defaults];
		NSFont *font = [NSFont fontWithName: [defs objectForKey: @"FontName"]
									   size: [defs floatForKey: @"FontSize"]];
		
		[fontView setFont: font];
	}
	return self;
}

- (IBAction)chooseLibraryPath:(id)sender {
	NSOpenPanel *open = [NSOpenPanel openPanel];
	[open setCanChooseDirectories: YES];
	[open setCanChooseFiles: NO];
	[open setAllowsMultipleSelection: NO];
	
	[open beginSheetForDirectory: nil
							file: nil 
				  modalForWindow: [self window]
				   modalDelegate: self 
				  didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
					 contextInfo: nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSString *path = [sheet filename];
	[[NSUserDefaults standardUserDefaults] setObject: path
											  forKey: @"SourceDirectoryPath"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	NSUserDefaults *defs = [defsController defaults];
	[defs setValue: [[fontView font] fontName] forKey: @"FontName"];
	[defs setFloat: [[fontView font] pointSize] forKey: @"FontSize"];
}
@end
