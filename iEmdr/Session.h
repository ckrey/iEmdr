//
//  Session.h
//  iEmdr
//
//  Created by Christoph Krey on 22.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSNumber * actualDuration;
@property (nonatomic, retain) NSNumber * canvas;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * form;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSNumber * hue;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * sound;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Client *hasClient;

@end
