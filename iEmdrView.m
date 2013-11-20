//
//  iEmdrView.m
//  iEmdr
//
//  Created by Christoph Krey on 02.07.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "iEmdrView.h"
#import "IEMDRViewController.h"

@interface iEmdrView()

@property (nonatomic) BOOL left;
@property (nonatomic) BOOL animating;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

@end

@implementation iEmdrView

// beats per minute
@synthesize bpm = _bpm;
#define BPM_MAX 180.0
#define BPM_MIN 10.0
#define BPM_DEFAULT 93.0

- (void)setBpm:(float)bpm
{
    if ((bpm >= BPM_MIN) && (bpm <= BPM_MAX)) _bpm = bpm;
    if (!self.animating) [self setNeedsDisplay];
    if (self.observer) [self.observer performSelector:@selector(valueChanged)];
}

- (float)bpm
{
    if ((_bpm < BPM_MIN) || (_bpm > BPM_MAX)) [self setBpm:BPM_DEFAULT];
    return _bpm;
}

+ (float)minBpm
{
    return BPM_MIN;
}
+ (float)maxBpm
{
    return BPM_MAX;
}
+ (float)defaultBpm
{
    return BPM_DEFAULT;
}

// radius
@synthesize radius = _radius;
#define RADIUS_MAX 100.0
#define RADIUS_MIN 5.0
#define RADIUS_DEFAULT 25.0

- (void)setRadius:(float)radius
{
    if ((radius >= RADIUS_MIN) && (radius <= RADIUS_MAX)) _radius = radius;
    if (!self.animating) [self setNeedsDisplay];
    if (self.observer) [self.observer performSelector:@selector(valueChanged)];
}

- (float)radius
{
    if ((_radius < RADIUS_MIN) || (_radius > RADIUS_MAX)) [self setRadius:RADIUS_DEFAULT];
    return _radius;
}

+ (float)minRadius
{
    return RADIUS_MIN;
}
+ (float)maxRadius
{
    return RADIUS_MAX;
}
+ (float)defaultRadius
{
    return RADIUS_DEFAULT;
}

// background
@synthesize background = _background;
#define BACKGROUND_MAX 1.0
#define BACKGROUND_MIN 0.0
#define BACKGROUND_DEFAULT 0.9

- (void)setBackground:(float)background
{
    if ((background >= BACKGROUND_MIN) && (background <= BACKGROUND_MAX)) _background = background;
    UIColor *backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:background alpha:1.0];
    self.superview.backgroundColor = backgroundColor;

    if (self.observer) [self.observer performSelector:@selector(valueChanged)];

}

- (float)background
{
    if ((_background < BACKGROUND_MIN) || (_background > BACKGROUND_MAX)) [self setBackground:BACKGROUND_DEFAULT];
    return _background;
}

+ (float)minBackground
{
    return BACKGROUND_MIN;
}
+ (float)maxBackground
{
    return BACKGROUND_MAX;
}
+ (float)defaultBackground
{
    return BACKGROUND_DEFAULT;
}


// duration
@synthesize duration = _duration;
#define DURATION_MAX 600.0
#define DURATION_MIN 10.0
#define DURATION_DEFAULT 60.0

- (void)setDuration:(float)duration
{
    if ((duration >= DURATION_MIN) && (duration <= DURATION_MAX)) {
        _duration = duration;
    }
    if (self.observer) [self.observer performSelector:@selector(valueChanged)];
}

- (float)duration
{
    if ((_duration < DURATION_MIN) || (_duration > DURATION_MAX)) [self setDuration:DURATION_DEFAULT];
    return _duration;
}

+ (float)minDuration
{
    return DURATION_MIN;
}
+ (float)maxDuration
{
    return DURATION_MAX;
}
+ (float)defaultDuration
{
    return DURATION_DEFAULT;
}

// onOff
- (void)setOn:(BOOL)on
{
    _on = on;
    if (on) {
        self.startTime = [NSDate date];
        self.endTime = nil;
        [UIApplication sharedApplication].idleTimerDisabled = TRUE;
        if (!self.animating) [self setNeedsDisplay];
    } else {
        [UIApplication sharedApplication].idleTimerDisabled = FALSE;
        self.endTime = [NSDate date];
    }
    if (self.observer) [self.observer performSelector:@selector(valueChanged)];
}

// color
#define COLOR_DEFAULT [UIColor redColor]
- (void)setColor:(UIColor *)color
{
    _color = color;
    if (!self.animating) [self setNeedsDisplay];
    if (self.observer) [self.observer performSelector:@selector(valueChanged)];
}

// progress
- (float)progress
{
    if (self.endTime && self.startTime) {
        return [self.endTime timeIntervalSinceDate:self.startTime] / self.duration;
    }
    if (self.startTime) {
        return [[NSDate date] timeIntervalSinceDate:self.startTime] / self.duration;
    }
    return 0.0;
}

- (void)layoutSubviews
{
    if (!self.animating) [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    
    [circle addClip];
    
    [self.color setFill];
    UIRectFill(self.bounds);
    
    [self.color setStroke];
    [circle stroke];
    
    NSTimeInterval duration = 60.0/2.0/self.bpm;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCrossDissolve |
                                UIViewAnimationOptionAllowUserInteraction |
                                UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void){
                         self.animating = TRUE;
                         self.bounds = CGRectMake(0.0, 0.0, self.radius*2.0, self.radius*2.0);
                         self.center = CGPointMake(self.left?
                                                   self.bounds.size.width/2.0:
                                                   self.superview.bounds.size.width-self.bounds.size.width/2.0,
                                                   self.superview.bounds.size.height/2.0);
                         self.left = !self.left;
                     }
                     completion:^(BOOL finished){
                         self.animating = FALSE;
                         if (self.on) {
                             [self setNeedsDisplay];
                             if ([[NSDate date] timeIntervalSinceDate:self.startTime] > self.duration) {
                                 self.on = FALSE;
                                 if (self.observer) {
                                     [self.observer performSelector:@selector(sessionFinished)];
                                 }
                             }
                         }
                         if (self.observer) {
                             [self.observer performSelector:@selector(valueChanged)];
                         }
                     }];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.bpm = BPM_DEFAULT;
    self.radius = RADIUS_DEFAULT;
    self.background = BACKGROUND_DEFAULT;
    self.duration = DURATION_DEFAULT;
    self.color = COLOR_DEFAULT;
    self.on = FALSE;
    
    return self;
}


@end
