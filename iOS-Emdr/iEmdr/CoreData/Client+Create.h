//
//  Client+Create.h
//  iEmdr
//
//  Created by Christoph Krey on 09.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Client.h"
#import <AddressBook/AddressBook.h>

@interface Client (Create)
+ (Client *)clientWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+ (ABAddressBookRef)theABRef;



@end
