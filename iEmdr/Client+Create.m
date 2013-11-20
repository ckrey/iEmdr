//
//  Client+Create.m
//  iEmdr
//
//  Created by Christoph Krey on 09.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Client+Create.h"

@implementation Client (Create)

+ (Client *)clientWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
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

+ (ABAddressBookRef)theABRef
{
    static ABAddressBookRef ab = nil;
    static BOOL isGranted = YES;
    
    if (!ab) {
        if (isGranted) {
#ifdef DEBUG
            NSLog(@"ABAddressBookCreateWithOptions");
#endif
            CFErrorRef error;
            ab = ABAddressBookCreateWithOptions(NULL, &error);
            if (!ab) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                NSLog(@"ABAddressBookCreateWithOptions not successfull %@", errorDescription);
                CFRelease(errorDescription);
                isGranted = NO;
            }
        }
    }
    return ab;
}



@end
