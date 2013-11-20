//
//  Session+Create.h
//  iEmdr
//
//  Created by Christoph Krey on 09.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "Session.h"
#import "Client+Create.h"

@interface Session (Create)

+ (Session *)sessionWithTimestamp:(NSDate *)timestamp
                         duration:(NSNumber *)duration
                   actualDuration:(NSNumber *)actualDuration
                           canvas:(NSNumber *)canvas
                              hue:(NSNumber *)hue
                             size:(NSNumber *)size
                        frequency:(NSNumber *)frequency
                             form:(NSNumber *)form
                           client:(Client *)client
           inManagedObjectContext:(NSManagedObjectContext *)context;
@end
