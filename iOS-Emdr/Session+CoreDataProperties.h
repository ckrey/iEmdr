//
//  Session+CoreDataProperties.h
//  iEmdr
//
//  Created by Christoph Krey on 29.10.19.
//  Copyright © 2019 Christoph Krey. All rights reserved.
//
//

#import "Session+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Session (CoreDataProperties)

+ (NSFetchRequest<Session *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *actualDuration;
@property (nullable, nonatomic, copy) NSNumber *canvas;
@property (nullable, nonatomic, copy) NSNumber *duration;
@property (nullable, nonatomic, copy) NSNumber *form;
@property (nullable, nonatomic, copy) NSNumber *frequency;
@property (nullable, nonatomic, copy) NSNumber *hue;
@property (nullable, nonatomic, copy) NSNumber *size;
@property (nullable, nonatomic, copy) NSNumber *sound;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, retain) Client *hasClient;

@end

NS_ASSUME_NONNULL_END
