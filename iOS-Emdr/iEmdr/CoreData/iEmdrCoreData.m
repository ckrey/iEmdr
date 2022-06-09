//
//  iEmdrCoreData.m
//  iEmdr
//
//  Created by Christoph Krey on 29.09.13.
//  Copyright © 2013-2022 Christoph Krey. All rights reserved.
//

#import "iEmdrCoreData.h"
#import "CocoaLumberjack.h"

@interface iEmdrCoreData()

@end

@implementation iEmdrCoreData
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (id)init
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"iEmdr"];
    self = [super initWithFileURL:url];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    self.persistentStoreOptions = options;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        DDLogVerbose(@"Document creation %@\n", [url path]);
        [self saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                DDLogVerbose(@"Document created %@\n", [url path]);
            }
        }];
    } else {
        if (self.documentState == UIDocumentStateClosed) {
            DDLogVerbose(@"Document opening %@\n", [url path]);
            [self openWithCompletionHandler:^(BOOL success){
                if (success) {
                    DDLogVerbose(@"Document opened %@\n", [url path]);
                }
            }];
        } else {
            DDLogVerbose(@"Document used %@\n", [url path]);
        }
    }

    return self;
}

- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted
{
    DDLogError(@"CoreData handleError: %@", error);
    [self finishedHandlingError:error recovered:NO];
}

- (void)userInteractionNoLongerPermittedForError:(NSError *)error
{
    DDLogError(@"CoreData userInteractionNoLongerPermittedForError: %@", error);
}

@end
