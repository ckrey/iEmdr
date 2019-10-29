//
//  IEMDRBigViewController.m
//  iEmdr
//
//  Created by Christoph Krey on 23.11.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import "IemdrBigVC.h"
#import "IemdrScene.h"
#import <SpriteKit/SpriteKit.h>

@interface IemdrBigVC ()

@end

@implementation IemdrBigVC

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    IemdrScene *scene = [[IemdrScene alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    SKView *view = (SKView *)self.view;
    [view presentScene:scene];
}

@end
