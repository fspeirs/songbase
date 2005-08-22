//  Songbase_2AppDelegate.h
//  Songbase 2
//
//  Created by Fraser Speirs on 02/05/2005.
//  Copyright Connected Flow 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>

@class SBFullController;

@interface Songbase_2AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;

	IBOutlet NSArrayController *controller;
	IBOutlet NSTableView *table;
    IBOutlet NSWindow *prefsWindow;
	
	SBFullController *fullScreenController;
	
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

- (IBAction)showFullScreenWindow:(id)sender;

- (IBAction)showPreferences:(id)sender;

- (IBAction)importFiles:(id)sender;
- (void)processFile: (NSString *)path;

- (IBAction)makeSharp:(id)sender;
- (IBAction)makeFlat:(id)sender;

- (IBAction)exportSelectedSongs:(id)sender;
- (IBAction)exportIndex:(id)sender;
@end
