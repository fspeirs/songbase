#import "SBCatalogueController.h"
#import "SBCatalogue.h"
#import "SBFController.h"

@implementation SBCatalogueController
- (id)init {
	self = [super init];
	if(self) {
		[self setCatalogue: [SBCatalogue sharedCatalogue]];
		[NSBundle loadNibNamed: @"Catalogue" owner: self];
		
		[table setTarget: self];
		[table setDoubleAction: @selector(showSong:)];
	}
	return self;
}

- (IBAction)showSong: (id)sender {
	NSEvent *curEvt = [NSApp currentEvent];
	
	if([[aController selectedObjects] count] > 0) {
		id song = [[aController selectedObjects] objectAtIndex: 0];
		if(NSAlternateKeyMask == ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)) {
			NSDocumentController *docController = [NSDocumentController sharedDocumentController];
			id doc = [docController openUntitledDocumentOfType: @"SongBase Song" display: NO];
			[doc setFileName: [catalogue pathForSong:song]];
			[doc setSong: song];
			[doc showWindows];
		}
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName: @"SongSelected" object: song];
		}
	}
	
}

- (IBAction)reload : (id)sender {
	[searchField setStringValue: @""];
	[aController search: nil];
	[catalogue reload];
}

- (IBAction)exportIndexToRTF: (id)sender {
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel runModalForDirectory: nil file: nil];
	
	NSString *file = [savePanel filename];
	
	[[self catalogue] writeIndexToFile: file atomically: YES];
}

// =========================================================== 
// - catalogue:
// =========================================================== 
- (SBCatalogue *)catalogue {
    return catalogue; 
}

// =========================================================== 
// - setCatalogue:
// =========================================================== 
- (void)setCatalogue:(SBCatalogue *)aCatalogue {
    if (catalogue != aCatalogue) {
        [aCatalogue retain];
        [catalogue release];
        catalogue = aCatalogue;
    }
}
@end
