//
//  Client+Create.h
//  iEmdr
//
//  Created by Christoph Krey on 09.09.13.
//  Copyright © 2013-2018 Christoph Krey. All rights reserved.
//

#import "Client.h"
@interface Client (Create)
+ (Client *)clientWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;



@end
