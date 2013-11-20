//
//  Session.h
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Session : NSManagedObject

@property (nonatomic, retain) NSNumber * actualDuration;
@property (nonatomic, retain) NSNumber * canvas;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSNumber * hue;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSManagedObject *hasClient;

@end
