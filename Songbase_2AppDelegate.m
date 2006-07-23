//  Songbase_2AppDelegate.m
//  Songbase 2
//
//  Created by Fraser Speirs on 02/05/2005.
//  Copyright Connected Flow 2005 . All rights reserved.

#import "Songbase_2AppDelegate.h"
#import "SBFullController.h"
#import "SBSong.h"

@implementation Songbase_2AppDelegate

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
- (NSString *)applicationSupportFolder {
    NSString *applicationSupportFolder = nil;
    FSRef foundRef;
    OSErr err = FSFindFolder(kUserDomain, kApplicationSupportFolderType, kDontCreateFolder, &foundRef);
    if (err != noErr) {
        NSRunAlertPanel(@"Alert", @"Can't find application support folder", @"Quit", nil, nil);
        [[NSApplication sharedApplication] terminate:self];
    } else {
        unsigned char path[1024];
        FSRefMakePath(&foundRef, path, sizeof(path));
        applicationSupportFolder = [NSString stringWithUTF8String:(char *)path];
        applicationSupportFolder = [applicationSupportFolder stringByAppendingPathComponent:@"Songbase_2"];
    }
    return applicationSupportFolder;
}

- (NSManagedObjectContext *) managedObjectContext {
    NSError *error;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSFileManager *fileManager;
    NSPersistentStoreCoordinator *coordinator;
    
    if (managedObjectContext) {
        return managedObjectContext;
    }
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Songbase_2.xml"]];
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if ([coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        managedObjectContext = [[NSManagedObjectContext alloc] init];
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
					int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
					if (alertReturn == NSAlertAlternateReturn) {
						reply = NSTerminateCancel;	
					}
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
	[song setValue: [NSCalendarDate date] forKey: @"lastPlayed"];
	
	
	if(!fullScreenController) {
		fullScreenController = [[SBFullController alloc] init];
	}
	
	[fullScreenController setCurrentSong: song];
	[fullScreenController showWindow: self];
}

- (IBAction)showPreferences:(id)sender {
	[NSBundle loadNibNamed: @"Preferences" owner: self];	
	[prefsWindow makeKeyAndOrderFront: self];
}

- (IBAction)importFiles:(id)sender {
	NSOpenPanel *open = [NSOpenPanel openPanel];
	[open setCanChooseFiles: YES];
	[open setCanChooseDirectories: YES];
	[open setAllowsMultipleSelection: YES];
	[open setAllowedFileTypes: [NSArray arrayWithObject: @"songbase"]];
	
	[open beginSheetForDirectory: nil
							file: nil
				  modalForWindow: window
				   modalDelegate: self
				  didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
					 contextInfo: nil];
	
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if(returnCode == NSOKButton) {
		NSArray *files = [sheet filenames];
		NSEnumerator *en = [files objectEnumerator];
		NSString *path;
		while(path = [en nextObject])
			[self processFile: path];
	}
}

- (void)processFile: (NSString *)path {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
	
	NSString *copy = [dict objectForKey: @"copyright"];
	NSString *title = [dict objectForKey: @"title"];
	NSData *body = [dict objectForKey: @"body"];
	
	NSError *err;
	NSAttributedString *attrstr = [[NSAttributedString alloc] initWithData: body
																   options: nil documentAttributes: nil error: &err];
	
	NSMutableString *lyrics = [[NSMutableString alloc] init];
	[lyrics appendString: [attrstr string]];
	
	
	NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName: @"Song"
														 inManagedObjectContext: [self managedObjectContext]];
	
	[obj setValue: copy forKey: @"copyright"];
	[obj setValue: title forKey: @"title"];
	[obj setValue: lyrics forKey: @"lyrics"];
}

- (IBAction)makeSharp:(id)sender {
	/*NSManagedObject *song = [[controller selectedObjects] objectAtIndex: 0];

	NSString *songKey = [song valueForKey: @"songKey"];
	[song setValue: [NSString stringWithFormat: @"%@♭", songKey] forKey: @"songKey"];*/
}

- (IBAction)makeFlat:(id)sender {
	//NSManagedObject *song = [[controller selectedObjects] objectAtIndex: 0];	
}

- (IBAction)exportSelectedSongs:(id)sender {
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES];
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
		
		NSAttributedString *lyrics = [[NSAttributedString alloc] initWithString: [song valueForKey: @"lyrics"] attributes: bodyAttributes];
		[str appendAttributedString: lyrics];
		[str appendAttributedString: [[[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"\n\n%C", NSFormFeedCharacter]] autorelease]];
	}
	
	NSDictionary *payloadDict = [[NSDictionary dictionaryWithObjects: [NSArray arrayWithObject: str]
															 forKeys: [NSArray arrayWithObject: @"payload"]] retain];
	
	NSSavePanel *save = [NSSavePanel savePanel];
	[save beginSheetForDirectory: nil
							file: nil
				  modalForWindow: window
				   modalDelegate: self
				  didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
					 contextInfo: payloadDict];
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
	NSLog(songString);	
	
	NSDictionary *payloadDict = [[NSDictionary dictionaryWithObjects: [NSArray arrayWithObject: songString]
															 forKeys: [NSArray arrayWithObject: @"payload"]] retain];
	
	NSSavePanel *save = [NSSavePanel savePanel];
	[save beginSheetForDirectory: nil
							file: nil
				  modalForWindow: window
				   modalDelegate: self
				  didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
					 contextInfo: payloadDict];
}

- (IBAction)savePlayCountReport: (id)sender {
	NSError *err;

	NSFetchRequest *fReq = [[NSFetchRequest alloc] init];
	[fReq setEntity: [NSEntityDescription entityForName: @"Song" inManagedObjectContext: [self managedObjectContext]]];
	[fReq setPredicate: [NSPredicate predicateWithFormat: @"playcount > 0"]];

	NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
	
	NSAttributedString *tabString = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%C", NSTabCharacter]];
	
	NSEnumerator *en = [[[self managedObjectContext] executeFetchRequest: fReq error: &err] objectEnumerator];
	id song;
	while(song = [en nextObject]) {
		[attString appendAttributedString: [[[NSAttributedString alloc] initWithString: [song valueForKey: @"title"]] autorelease]];
		
		int i;
		for(i=0; i < 5; i++)
			[attString appendAttributedString: tabString];
		
		[attString appendAttributedString: [[[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%d", [[song valueForKey: @"playcount"] intValue]]] autorelease]];
		[attString appendAttributedString: [[[NSAttributedString alloc] initWithString: @"\n"] autorelease]];
	}
	
	NSDictionary *payloadDict = [[NSDictionary dictionaryWithObjects: [NSArray arrayWithObject: attString]
															 forKeys: [NSArray arrayWithObject: @"payload"]] retain];
	
	NSSavePanel *save = [NSSavePanel savePanel];
	[save beginSheetForDirectory: nil
							file: nil
				  modalForWindow: window
				   modalDelegate: self
				  didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
					 contextInfo: payloadDict];
}

- (IBAction)resetPlayCounts:(id)sender {
	int returnCode = NSRunAlertPanel(@"Reset Play Counts",
									 @"Are you sure you want to set all play counts to zero?  This cannot be undone.",
									 @"Cancel", @"Reset", nil);
	if(returnCode == NSAlertDefaultReturn)
		return;
			
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity: [NSEntityDescription entityForName: @"Song" inManagedObjectContext: [self managedObjectContext]]];

	NSError *err;
	NSArray *allSongs = [[self managedObjectContext] executeFetchRequest: req error: &err];
	
	if(allSongs) {
		NSEnumerator *en = [allSongs objectEnumerator];
		SBSong *song;
		while(song = [en nextObject]) {
			[song setValue: [NSNumber numberWithInt: 0] forKey: @"playcount"];
			[song setValue: nil forKey: @"lastPlayed"];
		}
	}
	else
		NSRunCriticalAlertPanel(@"Error Resetting Play Counts", [err localizedDescription], @"OK", nil, nil);
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if(returnCode == NSOKButton) {
		id data = [(NSDictionary *)contextInfo objectForKey: @"payload"];
		
		if(![data respondsToSelector: @selector(count)]) { // A string
			NSLog(@"Writing to file: %@", [sheet filename]);
			if([data isKindOfClass: [NSAttributedString class]])
				[[data RTFFromRange: NSMakeRange(0,[data length]) documentAttributes: nil] writeToFile: [sheet filename] atomically: YES]; 
			else
				[data writeToFile: [sheet filename] atomically: YES];	
		}
		else { //An array
			
		}
	}
}

@end
