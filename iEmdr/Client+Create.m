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
            CFErrorRef cfError;
            ab = ABAddressBookCreateWithOptions(NULL, &cfError);
            if (ab) {
#ifdef DEBUG
                NSLog(@"ABAddressBookCreateWithOptions successful");
#endif
            } else {
                CFStringRef errorDescription = CFErrorCopyDescription(cfError);
                [Client error:[NSString stringWithFormat:@"ABAddressBookCreateWithOptions not successfull %@", errorDescription]];
                CFRelease(errorDescription);
                isGranted = NO;
            }
            
#ifdef DEBUG
            NSLog(@"ABAddressBookRequestAccessWithCompletion");
#endif
            
            ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
                if (granted) {
#ifdef DEBUG
                    NSLog(@"ABAddressBookRequestAccessCompletionHandler successful");
#endif
                } else {
                    isGranted = NO;
                    CFRelease(ab);
                    ab = nil;
                }
            });
        } else {
            [Client error:[NSString stringWithFormat:@"ABAddressBookRequestAccessWithCompletion not successfull"]];
        }
        
    }
    
    return ab;
}

+ (void)error:(NSString *)message
{
#ifdef DEBUG
    NSLog(@"Client error %@", message);
#endif
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle mainBundle].infoDictionary[@"CFBundleName"]
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
    
}



@end
