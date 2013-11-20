//
//  iEmdrSessionTVC.h
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "Client.h"


@interface iEmdrSessionTVC : CoreDataTableViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) Client *client;
@end
