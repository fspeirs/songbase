/* SBCatalogueController */

#import <Cocoa/Cocoa.h>

@class SBCatalogue, SBFController;

@interface SBCatalogueController : NSWindowController
{
	SBCatalogue *catalogue;
	IBOutlet SBFController *aController;
	IBOutlet NSTableView *table;
	IBOutlet NSSearchField *searchField;
}

- (IBAction)reload : (id)sender;
- (IBAction)exportIndexToRTF: (id)sender;

- (SBCatalogue *)catalogue;
- (void)setCatalogue:(SBCatalogue *)aCatalogue;
@end
