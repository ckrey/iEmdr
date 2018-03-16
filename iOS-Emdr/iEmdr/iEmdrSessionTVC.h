//
//  iEmdrSessionTVC.h
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright © 2013-2018 Christoph Krey. All rights reserved.
//

#import "CoreDataTVC.h"
#import "Client.h"


@interface iEmdrSessionTVC : CoreDataTVC <UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) Client *client;
@end
