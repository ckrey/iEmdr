//
//  iEmdrClientTVC.h
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright © 2013-2022 Christoph Krey. All rights reserved.
//

#import "CoreDataTVC.h"
#import "Session+CoreDataClass.h"
#if !TARGET_OS_MACCATALYST
#import <AddressBookUI/AddressBookUI.h>
#endif

@interface iEmdrClientTVC : CoreDataTVC
@end
