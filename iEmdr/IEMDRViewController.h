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


@interface IEMDRViewController : UIViewController

@property (weak, nonatomic) SKView *big;
@property (strong, nonatomic) Client *clientToRun;
- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem;
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;
- (void)sessionFinished;


@end
