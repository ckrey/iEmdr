//
//  iEmdrClientTVC.h
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Session+Create.h"
#import <AddressBookUI/AddressBookUI.h>


@interface iEmdrClientTVC : CoreDataTableViewController <ABPeoplePickerNavigationControllerDelegate, UISplitViewControllerDelegate>
@end
