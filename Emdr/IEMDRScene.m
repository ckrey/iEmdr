//
//  IEMDRScene.m
//  iEmdr
//
//  Created by Christoph Krey on 19.11.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import "IEMDRScene.h"
#import "CocoaLumberjack.h"

@interface IemdrScene ()
@property BOOL contentCreated;
@end

@implementation IemdrScene
static const DDLogLevel ddLogLevel = DDLogLevelWarning;

- (void)update:(NSTimeInterval)currentTime {
    DDLogVerbose(@"IemdrScene update:%f", currentTime);
}

- (void)didEvaluateActions {
    DDLogVerbose(@"IemdrScene didEvaluateActions");
}

- (void)didMoveToView: (SKView *) view {
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents {
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self newNode]];
}

- (SKShapeNode *)newNode {
    SKShapeNode *node = [[SKShapeNode alloc] init];
    node.name = @"node";
    node.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    node.path = CGPathCreateWithEllipseInRect(CGRectMake(-25, -25, 50, 50), NULL);
    node.antialiased = NO;
    node.blendMode = SKBlendModeReplace;
    node.fillColor = [UIColor blackColor];
    node.strokeColor = [UIColor clearColor];
    node.glowWidth = 0.0;
    node.lineWidth = 1.0;
    return node;
}

@end
