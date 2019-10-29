//
//  Session+CoreDataClass.h
//  iEmdr
//
//  Created by Christoph Krey on 29.10.19.
//  Copyright © 2019 Christoph Krey. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client;

NS_ASSUME_NONNULL_BEGIN

@interface Session : NSManagedObject

+ (Session *)sessionWithTimestamp:(NSDate *)timestamp
              duration:(NSNumber *)duration
        actualDuration:(NSNumber *)actualDuration
                canvas:(NSNumber *)canvas
                   hue:(NSNumber *)hue
                  size:(NSNumber *)size
             frequency:(NSNumber *)frequency
                  form:(NSNumber *)form
                 sound:(NSNumber *)sound
                client:(Client *)client
inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Session+CoreDataProperties.h"
