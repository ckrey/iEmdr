//
//  IEMDRViewController.h
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client+Create.h"
#import "Session+Create.h"
#import <SpriteKit/SpriteKit.h>


@interface IemdrVC : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Client *clientToRun;
- (void)sessionFinished;


@end
