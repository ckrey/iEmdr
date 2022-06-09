//
//  Client+CoreDataProperties.h
//  iEmdr
//
//  Created by Christoph Krey on 29.10.19.
//  Copyright © 2019-2022 Christoph Krey. All rights reserved.
//
//

#import "Client+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Client (CoreDataProperties)

+ (NSFetchRequest<Client *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Session *> *hasSessions;

@end

@interface Client (CoreDataGeneratedAccessors)

- (void)addHasSessionsObject:(Session *)value;
- (void)removeHasSessionsObject:(Session *)value;
- (void)addHasSessions:(NSSet<Session *> *)values;
- (void)removeHasSessions:(NSSet<Session *> *)values;

@end

NS_ASSUME_NONNULL_END
