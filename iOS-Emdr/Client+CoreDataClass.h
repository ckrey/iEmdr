//
//  Client+CoreDataClass.h
//  iEmdr
//
//  Created by Christoph Krey on 29.10.19.
//  Copyright © 2019 Christoph Krey. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

NS_ASSUME_NONNULL_BEGIN

@interface Client : NSManagedObject
+ (Client *)clientWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Client+CoreDataProperties.h"
