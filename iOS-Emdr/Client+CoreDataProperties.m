//
//  Client+CoreDataProperties.m
//  iEmdr
//
//  Created by Christoph Krey on 29.10.19.
//  Copyright © 2019 Christoph Krey. All rights reserved.
//
//

#import "Client+CoreDataProperties.h"

@implementation Client (CoreDataProperties)

+ (NSFetchRequest<Client *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Client"];
}

@dynamic identifier;
@dynamic name;
@dynamic hasSessions;

@end
