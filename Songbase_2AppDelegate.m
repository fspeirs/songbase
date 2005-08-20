//  Songbase_2AppDelegate.m
//  Songbase 2
//
//  Created by Fraser Speirs on 02/05/2005.
//  Copyright Connected Flow 2005 . All rights reserved.

#import "Songbase_2AppDelegate.h"
#import "SBFullController.h"

@implementation Songbase_2AppDelegate

- (void)awakeFromNib {
	[table setTarget: self];
	[table setDoubleAction: @selector(showFullScreenWindow:)];
	netService = [[NSNetService alloc] initWithDomain: @"" type: @"_songbase._tcp." name: @"Songbase" port:8080];
	NSDictionary *dict = [NSDictionary dictionaryWithObject: @"Rect" forKey: @"{{0, 52}, {1295, 843}}"];
	[netService setTXTRecordData: [NSNetService dataFromTXTRecordDictionary: dict]];
	[netService setDelegate: self];
	[netService publish];
	
	// Register for scroll notification
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(songDidScroll:)
												 name: @"SongbaseScrollEvent"
											   object: nil];
}

// Scroll event
- (void)songDidScroll:(NSNotification *)note {
	NSString *newRectString = [note object];
	NSDictionary *txtDict = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: @"Hello", newRectString, nil]
														forKeys: [NSArray arrayWithObjects: @"Message", @"Rect", nil]];
	NSLog([txtDict description]);
	[netService setTXTRecordData: [NSNetService dataFromTXTRecordDictionary: txtDict]];
}

// Rendezvous delegate
- (void)netServiceWillPublish:(NSNetService *)netService {
	NSLog(@"Netservice will publish");	
}

- (void)netService:(NSNetService *)netService didNotPublish:(NSDictionary *)errorDict {
	NSLog(@"Problem publishing: %@", [errorDict description]);
	int errorCode = [[errorDict objectForKey: NSNetServicesErrorCode] intValue];
	NSLog(@"Error code: %d", errorCode);
	switch(errorCode) {
		case NSNetServicesUnknownError:
			NSLog(@"NSNetServicesUnknownError");
			break;
		case NSNetServicesCollisionError:
			NSLog(@"The service could not be published because the name is already in use. The name could be in use locally or on another system.");
			break;
		case NSNetServicesNotFoundError:
			NSLog(@"The service could not be found on the network.");
			break;
		case NSNetServicesActivityInProgress:
			NSLog(@"The net service cannot process the request at this time. No additional information about the network state is known.");
			break;
		case NSNetServicesBadArgumentError:
			NSLog(@"An invalid argument was used when creating the NSNetService object.");
			break;
		case NSNetServicesCancelledError:
			NSLog(@"The client canceled the action.");
			break;
		case NSNetServicesInvalidError:
			NSLog(@"The net service was improperly configured.");
			break;
		case NSNetServicesTimeoutError:
			NSLog(@"Timed out");
	}
}

- (void)netServiceDidStop:(NSNetService *)theNetService {
	[netService release];
	netService = nil;
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

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	[netService stop];
	
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
	NSManagedObject *song = [[controller selectedObjects] objectAtIndex: 0];

	NSString *songKey = [song valueForKey: @"songKey"];
	[song setValue: [NSString stringWithFormat: @"%@♭", songKey] forKey: @"songKey"];
}

- (IBAction)makeFlat:(id)sender {
	//NSManagedObject *song = [[controller selectedObjects] objectAtIndex: 0];	
}

- (IBAction)exportSelectedSongs:(id)sender {

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

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if(returnCode == NSOKButton) {
		id data = [(NSDictionary *)contextInfo objectForKey: @"payload"];
		
		if(![data respondsToSelector: @selector(count)]) { // A string
			NSLog(@"Writing to file: %@", [sheet filename]);
			[data writeToFile: [sheet filename] atomically: YES];	
		}
		else { //An array
			
		}
		
		[contextInfo release];
	}
}
@end
