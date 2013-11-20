//
//  IEMDRScene.m
//  iEmdr
//
//  Created by Christoph Krey on 19.11.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "IEMDRScene.h"

@interface IEMDRScene ()
@property BOOL contentCreated;
@end

@implementation IEMDRScene

- (void)didMoveToView: (SKView *) view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self newNode]];
}

- (SKShapeNode *)newNode{
    SKShapeNode *node = [[SKShapeNode alloc] init];
    node.name = @"node";
    node.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    node.path = CGPathCreateWithEllipseInRect(CGRectMake(-25, -25, 50, 50), NULL);
    node.antialiased = NO;
    node.blendMode = SKBlendModeAlpha;
    node.fillColor = [UIColor redColor];
    node.strokeColor = [UIColor redColor];
    node.glowWidth = 0.0;
    node.lineWidth = 1.0;
    return node;
}

@end
