//
//  iEmdrView.h
//  iEmdr
//
//  Created by Christoph Krey on 02.07.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iEmdrView : UIView
@property (nonatomic) float bpm;
+ (float)maxBpm;
+ (float)minBpm;
+ (float)defaultBpm;

@property (strong, nonatomic) UIColor *color;

@property (nonatomic) float background;
+ (float)maxBackground;
+ (float)minBackground;
+ (float)defaultBackground;

@property (nonatomic) BOOL on;

@property (nonatomic) float duration;
+ (float)maxDuration;
+ (float)minDuration;
+ (float)defaultDuration;

@property (readonly, nonatomic) float progress;

@property (nonatomic) float radius;
+ (float)maxRadius;
+ (float)minRadius;
+ (float)defaultRadius;

@end
