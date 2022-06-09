//
//  Client+CoreDataClass.m
//  iEmdr
//
//  Created by Christoph Krey on 29.10.19.
//  Copyright © 2019-2022 Christoph Krey. All rights reserved.
//
//

#import "Client+CoreDataClass.h"

@implementation Client

+ (Client *)clientWithName:(NSString *)name
    inManagedObjectContext:(NSManagedObjectContext *)context {
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
        client.identifier = nil;

    } else {
        // client exists already
        client = [matches lastObject];
    }
    return client;
}

@end
