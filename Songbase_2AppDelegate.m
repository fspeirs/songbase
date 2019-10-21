//  Songbase_2AppDelegate.m
//  Songbase 2
//
//  Created by Fraser Speirs on 02/05/2005.
//  Copyright Connected Flow 2005 . All rights reserved.

#import "Songbase_2AppDelegate.h"
#import "SBFullController.h"
#import "SBSong.h"
#import "SBIntegerToStringVT.h"

@implementation Songbase_2AppDelegate
+ (void)initialize {
	[NSValueTransformer setValueTransformer: [[[SBIntegerToStringVT alloc] init] autorelease]
									forName: @"SBIntegerToStringVT"];
}

- (void)awakeFromNib {
	[table setTarget: self];
	[table setDoubleAction: @selector(showFullScreenWindow:)];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel) return managedObjectModel;
	
	NSMutableSet *allBundles = [[NSMutableSet alloc] init];
	[allBundles addObject: [NSBundle mainBundle]];
	[allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    
    return managedObjectModel;
}

/* Change this path/code to point to your App's data store. */
- (NSURL *)applicationSupportFolderURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *appSupportURL = [fileManager URLsForDirectory: NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    if([appSupportURL count] == 0) {
        NSError *err = [NSError errorWithDomain:NSCocoaErrorDomain code: 100 userInfo: [NSDictionary dictionaryWithObjectsAndKeys: NSLocalizedDescriptionKey, @"Can't find application support folder", nil]];
        [self abortSetupWithError: err];
    }
    
    return [appSupportURL firstObject];
}

- (void)abortSetupWithError:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithError: error];
    [alert runModal];
    [[NSApplication sharedApplication] terminate:self];
}

- (NSManagedObjectContext *) managedObjectContext {
    NSError *error;
    NSURL *url;
    NSFileManager *fileManager;
    NSPersistentStoreCoordinator *coordinator;
    
    if (managedObjectContext) {
        return managedObjectContext;
    }
    
    fileManager = [NSFileManager defaultManager];
    NSURL *applicationSupportFolder = [self applicationSupportFolderURL];
    if ( ![fileManager fileExistsAtPath: [applicationSupportFolder path] isDirectory:NULL] ) {
        NSError *err = nil;
        [fileManager createDirectoryAtPath: [applicationSupportFolder path] withIntermediateDirectories: YES attributes: nil error: &err];
        if(err) {
            [self abortSetupWithError: err];
        }
    }
    
    url = [applicationSupportFolder URLByAppendingPathComponent: @"Songbase_2.xml"];
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if ([coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    } else {
        [[NSApplication sharedApplication] presentError:error];
    }    
    [coordinator release];
    
    return managedObjectContext;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

- (IBAction) saveAction:(id)sender {
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)searchSongsAction:(id)sender {
	[window makeFirstResponder: searchField];	
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    NSError *error;
    NSManagedObjectContext *context;
    int reply = NSTerminateNow;
    
    context = [self managedObjectContext];
    if (context != nil) {
        if ([context commitEditing]) {
            if (![context save:&error]) {
				
				// This default error handling implementation should be changed to make sure the error presented includes application specific error recovery. For now, simply display 2 panels.
                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
				if (errorResult == YES) { // Then the error was handled
					reply = NSTerminateCancel;
				} else {
					
					// Error handling wasn't implemented. Fall back to displaying a "quit anyway" panel.
					[[NSAlert alertWithError: error] runModal];
				}
            }
        } else {
            reply = NSTerminateCancel;
        }
    }
    return reply;
}

- (IBAction)showFullScreenWindow:(id)sender {
	NSManagedObject *song = [[controller selectedObjects] objectAtIndex: 0];
	
	// Bump the playcount here
	int count = [[song valueForKey: @"playcount"] intValue];
	[song setValue: [NSNumber numberWithInt: count+1] forKey: @"playcount"];
	[song setValue: [NSDate date] forKey: @"lastPlayed"];
	
	
	if(!fullScreenController) {
		fullScreenController = [[SBFullController alloc] init];
	}
	
	[fullScreenController setCurrentSong: song];
	[fullScreenController showWindow: self];
}

- (IBAction)showPreferences:(id)sender {
    [[NSBundle mainBundle] loadNibNamed: @"Preferences" owner: self topLevelObjects: &prefsTopLevelObjects];
	[prefsWindow makeKeyAndOrderFront: self];
}

- (IBAction)importFiles:(id)sender {
	NSOpenPanel *open = [NSOpenPanel openPanel];
	[open setCanChooseFiles: YES];
	[open setCanChooseDirectories: YES];
	[open setAllowsMultipleSelection: YES];
	[open setAllowedFileTypes: [NSArray arrayWithObject: @"songbase"]];
    
    [open beginSheetModalForWindow: window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK){
            NSArray *files = [open URLs];
            NSEnumerator *en = [files objectEnumerator];
            NSURL *url;
            while(url = [en nextObject]) {
                [self processFile: [url path]];
            }
        }
    }];
	
}

- (void)processFile: (NSString *)path {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
	
	NSString *copy = [dict objectForKey: @"copyright"];
	NSString *title = [dict objectForKey: @"title"];
	NSData *body = [dict objectForKey: @"body"];
	
    NSError *err = nil;
    NSAttributedString *attrstr = [[[NSAttributedString alloc] initWithData: body
                                                                    options: [NSDictionary dictionary]
                                                         documentAttributes: nil
                                                                      error: &err] autorelease];
	
	NSMutableString *lyrics = [[NSMutableString alloc] init];
	[lyrics appendString: [attrstr string]];
	
	
	NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName: @"Song"
														 inManagedObjectContext: [self managedObjectContext]];
	
	[obj setValue: copy forKey: @"copyright"];
	[obj setValue: title forKey: @"title"];
	[obj setValue: lyrics forKey: @"lyrics"];
    [lyrics release];
}

- (IBAction)makeSharp:(id)sender {
	/*NSManagedObject *song = [[controller selectedObjects] objectAtIndex: 0];

	NSString *songKey = [song valueForKey: @"songKey"];
	[song setValue: [NSString stringWithFormat: @"%@♭", songKey] forKey: @"songKey"];*/
}

- (IBAction)makeFlat:(id)sender {
	//NSManagedObject *song = [[controller selectedObjects] objectAtIndex: 0];	
}

- (IBAction)exportAllSongsAsRTF:(id)sender {
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
	NSSortDescriptor *desc = [[[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES] autorelease];
	NSArray *songArray = [[controller content] sortedArrayUsingDescriptors: [NSArray arrayWithObject: desc]];

	NSEnumerator *songEnumerator = [songArray objectEnumerator];
	id song;
	while(song = [songEnumerator nextObject]) {
		NSDictionary *titleAtts = [NSDictionary dictionaryWithObject: [NSFont fontWithName: @"Helvetica Bold" size: 12] forKey: NSFontAttributeName];
		NSDictionary *bodyAttributes = [NSDictionary dictionaryWithObject: [NSFont fontWithName: @"Helvetica" size: 12] forKey: NSFontAttributeName];
		
		NSAttributedString *title = [[NSAttributedString alloc] initWithString: [song valueForKey: @"title"] attributes: titleAtts];
		[str appendAttributedString: title];
		[title release];
		
		[str appendAttributedString: [[[NSAttributedString alloc] initWithString: @"\n\n" attributes: bodyAttributes] autorelease]];
		
		NSAttributedString *lyrics = [[[NSAttributedString alloc] initWithString: [song valueForKey: @"lyrics"] attributes: bodyAttributes] autorelease];
		[str appendAttributedString: lyrics];
        [str appendAttributedString: [[[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"\n\n%C", (unichar)NSFormFeedCharacter]] autorelease]];
	}
	
	NSSavePanel *save = [NSSavePanel savePanel];
    [save beginSheetModalForWindow: window completionHandler: ^(NSInteger result) {
        if(result == NSModalResponseOK) {
            NSDictionary *documentAttributes = [NSDictionary dictionaryWithObjectsAndKeys: NSRTFTextDocumentType, NSDocumentTypeDocumentAttribute, nil];
            [[str RTFFromRange: NSMakeRange(0, [str length]) documentAttributes: documentAttributes] writeToURL: [save URL] atomically: YES];
        }
    }];
}
 
- (IBAction)exportSelectedSongsAsExportPackage:(id)sender {
	NSEnumerator *songs = [[controller selectedObjects] objectEnumerator]; 
	NSMutableArray *array = [NSMutableArray array];
	SBSong *song;
	while(song = [songs nextObject]) {
		[array addObject: [song propertyListRepresentation]];
	}
	
	[array writeToFile: [@"~/Desktop/SongBaseExport.plist" stringByExpandingTildeInPath]
			atomically: YES];
}

- (IBAction)exportIndex:(id)sender {
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES];
	NSArray *songArray = [[controller content] sortedArrayUsingDescriptors: [NSArray arrayWithObject: desc]];
	[desc release];
	
	NSMutableString *songString = [[NSMutableString alloc] initWithCapacity: 100];
		
	NSEnumerator *songEnumerator = [songArray objectEnumerator];
	id song;
	while(song = [songEnumerator nextObject]) {
		[songString appendString: [song valueForKey: @"title"]];
		[songString appendString: @"\n"];
	}
	NSLog(@"%@", songString);
	
	NSSavePanel *save = [NSSavePanel savePanel];
    save.nameFieldStringValue = @"Song Index.txt";
    [save beginSheetModalForWindow: window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSError *error = nil;
            [songString writeToURL: [save URL] atomically: YES encoding: NSUTF8StringEncoding error: &error];
            if(error) {
                [[NSAlert alertWithError: error] runModal];
            }
        }
    }];
}

- (IBAction)savePlayCountReport: (id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    save.nameFieldStringValue = @"Play Count Report.csv";
    [save beginSheetModalForWindow: window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSError *error = nil;
            NSMutableString *csv = [[self generateCSVPlayCountReport] retain];
            NSURL *theFile = [save URL];
            NSLog(@"Saving play count report to: %@", theFile);
            [csv writeToURL: theFile atomically:YES encoding:NSUTF8StringEncoding error: &error];
            if(error) {
                [[NSAlert alertWithError: error] runModal];
            }
            [csv release];
        }
    }];
}

- (NSMutableString *)generateCSVPlayCountReport {
    NSError *err = nil;
    NSFetchRequest *fReq = [[[NSFetchRequest alloc] init] autorelease];
    [fReq setEntity: [NSEntityDescription entityForName: @"Song" inManagedObjectContext: [self managedObjectContext]]];
    [fReq setPredicate: [NSPredicate predicateWithFormat: @"playcount > 0"]];
    NSEnumerator *en = [[[self managedObjectContext] executeFetchRequest: fReq error: &err] objectEnumerator];
    id song;
    NSMutableString *csv = [[NSMutableString alloc] init];
    while(song = [en nextObject]) {
        [csv appendFormat: @"\"%@\",%@\n", [song valueForKey: @"title"], [song valueForKey: @"playcount"]];
    }
    return [csv autorelease];
}

- (IBAction)resetPlayCounts:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.messageText = @"Reset Play Counts";
    alert.informativeText = @"Are you sure you want to set all play counts to zero?  This cannot be undone.";
    [alert addButtonWithTitle: @"Cancel"];
    [alert addButtonWithTitle: @"Reset Counts"];
    
    [alert beginSheetModalForWindow: window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertSecondButtonReturn) {
            NSFetchRequest *req = [[[NSFetchRequest alloc] init] autorelease];
            [req setEntity: [NSEntityDescription entityForName: @"Song" inManagedObjectContext: [self managedObjectContext]]];

            NSError *err = nil;
            NSArray *allSongs = [[self managedObjectContext] executeFetchRequest: req error: &err];
            
            if(allSongs) {
                NSEnumerator *en = [allSongs objectEnumerator];
                SBSong *song;
                while(song = [en nextObject]) {
                    [song setValue: [NSNumber numberWithInt: 0] forKey: @"playcount"];
                    [song setValue: nil forKey: @"lastPlayed"];
                }
            }
            else {
                [[NSAlert alertWithError: err] runModal];
            }
        }
    }];
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification {
    // If the screen configuration changed and we are left with only one screen, hide the overlay window even if it was up.
    if([[NSScreen screens] count] == 1) {
        [fullScreenController clearSongAndHideWindow];
    }
}

@end
