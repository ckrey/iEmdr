//
//  Session+CoreDataClass.m
//  iEmdr
//
//  Created by Christoph Krey on 29.10.19.
//  Copyright © 2019-2020 Christoph Krey. All rights reserved.
//
//

#import "Session+CoreDataClass.h"

@implementation Session

+ (Session *)sessionWithTimestamp:(NSDate *)timestamp
                         duration:(NSNumber *)duration
                   actualDuration:(NSNumber *)actualDuration
                           canvas:(NSNumber *)canvas
                              hue:(NSNumber *)hue
                             size:(NSNumber *)size
                           offset:(NSNumber *)offset
                        frequency:(NSNumber *)frequency
                             form:(NSNumber *)form
                            sound:(NSNumber *)sound
                           client:(Client *)client
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Session *session = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"timestamp = %@", timestamp];

    NSError *error = nil;

    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches || [matches count] > 1) {
        // handle error
    } else if (![matches count]) {
        //create new session
        session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:context];

        session.timestamp = timestamp;

        session.duration = duration;
        session.actualDuration = actualDuration;
        session.canvas = canvas;
        session.hue = hue;
        session.size = size;
        session.offset = offset;
        session.frequency = frequency;
        session.form = form;
        session.sound = sound;

        session.hasClient = client;
    } else {
        // session exists already
        session = [matches lastObject];
    }

    return session;
}

@end
