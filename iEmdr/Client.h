//
//  Client.h
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Client : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * abRef;
@property (nonatomic, retain) NSSet *hasSessions;
@end

@interface Client (CoreDataGeneratedAccessors)

- (void)addHasSessionsObject:(Session *)value;
- (void)removeHasSessionsObject:(Session *)value;
- (void)addHasSessions:(NSSet *)values;
- (void)removeHasSessions:(NSSet *)values;

@end
