//
//  Session+CoreDataProperties.m
//  iEmdr
//
//  Created by Christoph Krey on 06.03.20.
//  Copyright © 2020 Christoph Krey. All rights reserved.
//
//

#import "Session+CoreDataProperties.h"

@implementation Session (CoreDataProperties)

+ (NSFetchRequest<Session *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Session"];
}

@dynamic actualDuration;
@dynamic canvas;
@dynamic duration;
@dynamic form;
@dynamic frequency;
@dynamic hue;
@dynamic size;
@dynamic sound;
@dynamic timestamp;
@dynamic offset;
@dynamic hasClient;

@end
