//
//  Client+Create.m
//  iEmdr
//
//  Created by Christoph Krey on 09.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Client+Create.h"
#import <CocoaLumberjack/CocoaLumberJack.h>

@implementation Client (Create)
static const DDLogLevel ddLogLevel = DDLogLevelError;

+ (Client *)clientWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context {
    Client *client = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error = nil;
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count] > 1) {
        // handle error
    } else if (![matches count]) {
        //create new tag
        client = [NSEntityDescription insertNewObjectForEntityForName:@"Client" inManagedObjectContext:context];
        
        client.name = name;
        client.abRef = @(kABRecordInvalidID);
        
    } else {
        // client exists already
        client = [matches lastObject];
    }
    
    return client;
}

+ (ABAddressBookRef)theABRef {
    static ABAddressBookRef ab = nil;
    static BOOL isGranted = YES;
    
    if (!ab) {
        if (isGranted) {
            DDLogVerbose(@"ABAddressBookCreateWithOptions");
            CFErrorRef cfError;
            ab = ABAddressBookCreateWithOptions(NULL, &cfError);
            if (ab) {
                DDLogVerbose(@"ABAddressBookCreateWithOptions successful");
            } else {
                CFStringRef errorDescription = CFErrorCopyDescription(cfError);
                DDLogError(@"ABAddressBookCreateWithOptions not successfull %@", errorDescription);
                isGranted = NO;
            }
            
            DDLogVerbose(@"ABAddressBookRequestAccessWithCompletion");
            
            ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    DDLogVerbose(@"ABAddressBookRequestAccessCompletionHandler successful");
                } else {
                    isGranted = NO;
                    ab = nil;
                }
            });
        } else {
           DDLogError(@"ABAddressBookRequestAccessWithCompletion not successfull");
        }
        
    }
    
    return ab;
}

@end
