#import "SBAppDelegate.h"
#import "SBCatalogue.h"
#import "SBCatalogueController.h"
#import "SBFullController.h"
#import "SBPreferencesController.h"

@implementation SBAppDelegate
- (void)applicationDidFinishLaunching: (NSNotification *)note {
	catalogue = [SBCatalogue sharedCatalogue];
	[self showCatalogueWindow: self];
	
	fullController = [[SBFullController alloc] init];
}

- (BOOL)applicationShouldOpenUntitledFile: (NSApplication *)sender {
	return NO;
}

- (IBAction)showCatalogueWindow: (id)sender {
	if(!catController) {
		catController = [[SBCatalogueController alloc] init];
	}
	[catController showWindow: sender];
}

- (IBAction)showPreferencesWindow: (id)sender {
	if(!prefsController)
		prefsController = [[SBPreferencesController alloc] init];
	[prefsController showWindow: self];
}
@end
