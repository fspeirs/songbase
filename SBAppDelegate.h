/* SBAppDelegate */

#import <Cocoa/Cocoa.h>

@class SBCatalogue, SBCatalogueController, SBFullController, SBPreferencesController;

@interface SBAppDelegate : NSObject
{
	SBCatalogue *catalogue;
	SBCatalogueController *catController;
	SBFullController *fullController;
	SBPreferencesController *prefsController;
}

- (IBAction)showCatalogueWindow: (id)sender;
- (IBAction)showPreferencesWindow: (id)sender;
@end
