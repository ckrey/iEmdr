//
//  IEMDRScene.m
//  iEmdr
//
//  Created by Christoph Krey on 19.11.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
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

- (void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents {
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild:[self newNode]];
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

#define FLAT 0.75
+ (void)resetNode:(SKView *)spriteView
             form:(NSInteger)form
           offset:(double)offset
           canvas:(double)canvas
           radius:(NSInteger)radius
              hue:(double)hue
              bpm:(double)bpm {
    SKShapeNode *node = (SKShapeNode *)[spriteView.scene childNodeWithName:@"node"];
    [node removeAllActions];

    float w = spriteView.scene.frame.size.width;
    float h = spriteView.scene.frame.size.height;
    double oh = h/2;

    if (form == 0) {
        oh = h/2 + offset * h * FLAT;
    }

    SKAction *reset = [SKAction moveTo:CGPointMake(w/2, oh) duration:0];
    [node runAction:reset];

    spriteView.scene.backgroundColor = [UIColor colorWithHue:1.0
                                                  saturation:0.0
                                                  brightness:canvas
                                                       alpha:1.0];

    node.path = CGPathCreateWithEllipseInRect(CGRectMake(-radius,
                                                         -radius,
                                                         radius * 2,
                                                         radius * 2),
                                              NULL);

    node.fillColor = [UIColor colorWithHue:hue
                                saturation:1.0
                                brightness:1.0
                                     alpha:1.0];
    node.speed = bpm / 6;
}

+ (void)setNode:(SKView *)spriteView
           form:(NSInteger)form
         offset:(double)offset
          sound:(NSInteger)sound {
    SKNode *node = [spriteView.scene childNodeWithName:@"node"];
    [node removeAllActions];
    float w = spriteView.scene.frame.size.width;
    float h = spriteView.scene.frame.size.height;

    struct CGPath *pathl = CGPathCreateMutable();
    CGPathMoveToPoint(pathl, NULL, 0, 0);

    struct CGPath *pathr = CGPathCreateMutable();
    CGPathMoveToPoint(pathr, NULL, 0, 0);

    SKAction *reset;

    switch (form) {
        case 5:
            reset = [SKAction moveTo:CGPointMake(w/2, 0) duration:0];

            CGPathAddLineToPoint(pathl, NULL, 0, h);

            CGPathAddLineToPoint(pathr, NULL, 0, -h);
            break;

        case 4:
            reset = [SKAction moveTo:CGPointMake(0, h/2) duration:0];

            CGPathAddArc(pathl, NULL, +w/4, 0, w/4, M_PI, 2*M_PI, NO);
            CGPathAddArc(pathl, NULL, +w/4*3, 0, w/4, M_PI, 0, YES);

            CGPathAddArc(pathr, NULL, -w/4, 0, w/4, 0, M_PI, YES);
            CGPathAddArc(pathr, NULL, -w/4*3, 0, w/4, 2*M_PI, M_PI, NO);

            break;
        case 3:
            reset = [SKAction moveTo:CGPointMake(0, h/2) duration:0];

            CGPathAddArc(pathl, NULL, w*FLAT/4, 0, w*FLAT/4, M_PI, M_PI/2*3, NO);
            CGPathAddLineToPoint(pathl, NULL, w-w*FLAT/4, w*FLAT/4);
            CGPathAddArc(pathl, NULL, w-w*FLAT/4, 0, w*FLAT/4, M_PI/2, 0, YES);

            CGPathAddArc(pathr, NULL, -w*FLAT/4, 0, w*FLAT/4, 0, M_PI*3/2, YES);
            CGPathAddLineToPoint(pathr, NULL, -(w-w*FLAT/4), w*FLAT/4);
            CGPathAddArc(pathr, NULL, -(w-w*FLAT/4), 0, w*FLAT/4, M_PI/2, M_PI, NO);

            break;
        case 2:
            reset = [SKAction moveTo:CGPointMake(0, h-h/2*(1-FLAT)) duration:0];

            CGPathAddLineToPoint(pathl, NULL, w, -h*FLAT);

            CGPathAddLineToPoint(pathr, NULL, -w, h*FLAT);
            break;
        case 1:
            reset = [SKAction moveTo:CGPointMake(0, h/2*(1-FLAT)) duration:0];

            CGPathAddLineToPoint(pathl, NULL, w, h*FLAT);

            CGPathAddLineToPoint(pathr, NULL, -w, -h*FLAT);
            break;
        case 0:
        default: {
            double oh = h/2 + offset * h * FLAT;

            reset = [SKAction moveTo:CGPointMake(0, oh) duration:0];

            CGPathAddLineToPoint(pathl, NULL, w, 0);

            CGPathAddLineToPoint(pathr, NULL, -w, 0);
            break;
        }
    }

    SKAction *soundl;
    SKAction *soundr;

    switch (sound) {
        case 4:
            soundl = [SKAction playSoundFileNamed:@"snipl.m4a" waitForCompletion:NO];
            soundr = [SKAction playSoundFileNamed:@"snipr.m4a" waitForCompletion:NO];
            break;
        case 3:
            soundl = [SKAction playSoundFileNamed:@"dingl.m4a" waitForCompletion:NO];
            soundr = [SKAction playSoundFileNamed:@"dingr.m4a" waitForCompletion:NO];
            break;
        case 2:
            soundl = [SKAction playSoundFileNamed:@"bassdrum.m4a" waitForCompletion:NO];
            soundr = [SKAction playSoundFileNamed:@"snaire.m4a" waitForCompletion:NO];
            break;
        case 1:
            soundl = [SKAction playSoundFileNamed:@"pingl.m4a" waitForCompletion:NO];
            soundr = [SKAction playSoundFileNamed:@"pingr.m4a" waitForCompletion:NO];
            break;
        case 0:
        default:
            soundl = [SKAction playSoundFileNamed:@"tick.m4a" waitForCompletion:NO];
            soundr = [SKAction playSoundFileNamed:@"tock.m4a" waitForCompletion:NO];
            break;
    }

    SKAction *actionl = [SKAction followPath:pathl duration:5.0];
    SKAction *actionr = [SKAction followPath:pathr duration:5.0];

    SKAction *sequence = [SKAction sequence:@[reset, soundl, actionl, soundr, actionr]];

    [node runAction:[SKAction repeatActionForever:sequence]];
}

@end
