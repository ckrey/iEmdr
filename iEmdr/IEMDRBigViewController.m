//
//  IEMDRBigViewController.m
//  iEmdr
//
//  Created by Christoph Krey on 23.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "IEMDRBigViewController.h"
#import "IEMDRScene.h"
#import <SpriteKit/SpriteKit.h>

@interface IEMDRBigViewController ()

@end

@implementation IEMDRBigViewController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    IEMDRScene *scene = [[IEMDRScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    
    SKView *view = (SKView *)self.view;
    [view presentScene:scene];
}

@end
