//
//  ViewController.m
//  OwnTracksCTRLTV
//
//  Created by Christoph Krey on 26.09.15.
//  Copyright © 2015 OwnTracks. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "IemdrScene.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *stop;
@property (weak, nonatomic) IBOutlet UIButton *blank;

@property (weak, nonatomic) IBOutlet UIButton *canvasPlus;
@property (weak, nonatomic) IBOutlet UIButton *canvasMinus;

@property (weak, nonatomic) IBOutlet UIButton *huePlus;
@property (weak, nonatomic) IBOutlet UIButton *hueMinus;

@property (weak, nonatomic) IBOutlet UIButton *sizePlus;
@property (weak, nonatomic) IBOutlet UIButton *sizeMinus;

@property (weak, nonatomic) IBOutlet UIButton *bpmPlus;
@property (weak, nonatomic) IBOutlet UIButton *bpmMinus;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *durationMinus;
@property (weak, nonatomic) IBOutlet UIButton *durationPlus;

@property (weak, nonatomic) IBOutlet UIButton *snip;
@property (weak, nonatomic) IBOutlet UIButton *ding;
@property (weak, nonatomic) IBOutlet UIButton *drums;
@property (weak, nonatomic) IBOutlet UIButton *dong;
@property (weak, nonatomic) IBOutlet UIButton *tictoc;

@property (weak, nonatomic) IBOutlet UIButton *horizontal;
@property (weak, nonatomic) IBOutlet UIButton *up;
@property (weak, nonatomic) IBOutlet UIButton *down;
@property (weak, nonatomic) IBOutlet UIButton *infinity;
@property (weak, nonatomic) IBOutlet UIButton *eight;
@property (weak, nonatomic) IBOutlet UIButton *vertical;

@property (nonatomic) NSTimeInterval timePassed;
@property (strong, nonatomic) NSTimer *passingTimer;
@property (strong, nonatomic) NSDate *started;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetSprites];
}

- (IBAction)blankPressed:(id)sender {
    BOOL blank = [[NSUserDefaults standardUserDefaults] boolForKey:@"Blank"];
    blank = !blank;
    [[NSUserDefaults standardUserDefaults] setObject:@(blank) forKey:@"Blank"];
    [self.view setNeedsLayout];
}

- (IBAction)stopPressed:(id)sender {
    [self resetSprites];
    self.started = nil;

    self.progress.hidden = true;
    self.stop.hidden = true;

    self.button.hidden = false;
    self.blank.hidden = false;

    self.huePlus.hidden = false;
    self.hueMinus.hidden = false;

    self.canvasPlus.hidden = false;
    self.canvasMinus.hidden = false;

    self.bpmPlus.hidden = false;
    self.bpmMinus.hidden = false;
    self.bpmLabel.hidden = false;

    self.sizePlus.hidden = false;
    self.sizeMinus.hidden = false;

    self.durationLabel.hidden = false;
    self.durationMinus.hidden = false;
    self.durationPlus.hidden = false;

    self.vertical.hidden = false;
    self.up.hidden = false;
    self.down.hidden = false;
    self.infinity.hidden = false;
    self.eight.hidden = false;
    self.horizontal.hidden = false;

    self.tictoc.hidden = false;
    self.dong.hidden = false;
    self.drums.hidden = false;
    self.ding.hidden = false;
    self.snip.hidden = false;
    [self.view setNeedsFocusUpdate];
}

- (IBAction)buttonPressed:(UIButton *)sender {
    [self resetSprites];
    self.started = [NSDate date];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Blank"]) {
        self.progress.hidden = true;
        self.stop.hidden = true;
    } else {
        self.progress.hidden = false;
        self.stop.hidden = false;
    }

    self.button.hidden = true;
    self.blank.hidden = true;

    self.huePlus.hidden = true;
    self.hueMinus.hidden = true;

    self.bpmPlus.hidden = true;
    self.bpmMinus.hidden = true;
    self.bpmLabel.hidden = true;

    self.sizePlus.hidden = true;
    self.sizeMinus.hidden = true;

    self.canvasPlus.hidden = true;
    self.canvasMinus.hidden = true;

    self.durationLabel.hidden = true;
    self.durationMinus.hidden = true;
    self.durationPlus.hidden = true;

    self.vertical.hidden = true;
    self.up.hidden = true;
    self.down.hidden = true;
    self.infinity.hidden = true;
    self.eight.hidden = true;
    self.horizontal.hidden = true;

    self.tictoc.hidden = true;
    self.dong.hidden = true;
    self.drums.hidden = true;
    self.ding.hidden = true;
    self.snip.hidden = true;

    self.passingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(timePassed:)
                                                       userInfo:nil
                                                        repeats:YES];
    [self setNode:(SKView *)self.view];
    [self.view setNeedsFocusUpdate];
}

- (UIView *)preferredFocusedView {
    return self.button;
}

- (void)timePassed:(NSTimer *)timer
{
    float value = [[NSDate date] timeIntervalSinceDate:self.started] / [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"];
    NSLog(@"ticker %f", value);
    [self.progress setProgress:value animated:YES];

    if (value >= 1.0) {
        [self stopPressed:nil];
    }
}

- (void)resetSprites
{
    NSLog(@"resetSprites");
    if (self.passingTimer) {
        [self.passingTimer invalidate];
    }

    SKView *spriteView = (SKView *)self.view;
    SKShapeNode *node = (SKShapeNode *)[spriteView.scene childNodeWithName:@"node"];
    [node removeAllActions];

    float w = spriteView.scene.frame.size.width;
    float h = spriteView.scene.frame.size.height;
    SKAction *reset = [SKAction moveTo:CGPointMake(w/2, h/2) duration:0.25];
    [node runAction:reset];

    spriteView.scene.backgroundColor = [UIColor colorWithHue:1.0
                                                  saturation:0.0
                                                  brightness:[[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasVal"]
                                                       alpha:1.0];

    double radius = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusVal"];
    node.path = CGPathCreateWithEllipseInRect(CGRectMake(-radius, -radius, radius*2, radius*2), NULL);

    node.fillColor = [UIColor colorWithHue:[[NSUserDefaults standardUserDefaults] doubleForKey:@"HueVal"]
                                saturation:1.0
                                brightness:1.0
                                     alpha:1.0];
    node.speed = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"] / 6;

}
- (IBAction)canvasPlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasMax"];
    val = MIN(max,(val + (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"CanvasVal"];
    [self.view setNeedsLayout];
}
- (IBAction)canvasMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasMax"];
    val = MAX(min,(val - (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"CanvasVal"];
    [self.view setNeedsLayout];
}

- (IBAction)huePlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueMax"];
    val = MIN(max,(val + (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"HueVal"];
    [self.view setNeedsLayout];
}
- (IBAction)hueMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueMax"];
    val = MAX(min,(val - (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"HueVal"];
    [self.view setNeedsLayout];
}

- (IBAction)sizePlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusMax"];
    val = MIN(max,(val + (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"RadiusVal"];
    [self.view setNeedsLayout];
}
- (IBAction)sizeMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusMax"];
    val = MAX(min,(val - (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"RadiusVal"];
    [self.view setNeedsLayout];
}
- (IBAction)bpmPlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMMax"];
    val = MIN(max,(val + (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"BPMVal"];
    [self.view setNeedsLayout];
}
- (IBAction)bpmMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMMax"];
    val = MAX(min,(val - (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"BPMVal"];
    [self.view setNeedsLayout];
}
- (IBAction)durationPlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationMax"];
    val = MIN(max,(val + (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"DurationVal"];
    [self.view setNeedsLayout];
}
- (IBAction)durationMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationMin"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationMax"];
    val = MAX(min,(val - (max - min) / 16));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"DurationVal"];
    [self.view setNeedsLayout];
}
- (IBAction)tictoc:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"SoundVal"];
    [self.view setNeedsLayout];
}
- (IBAction)dong:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"SoundVal"];
    [self.view setNeedsLayout];
}
- (IBAction)drums:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:@"SoundVal"];
    [self.view setNeedsLayout];
}
- (IBAction)ding:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(3) forKey:@"SoundVal"];
    [self.view setNeedsLayout];
}
- (IBAction)snip:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(4) forKey:@"SoundVal"];
    [self.view setNeedsLayout];
}
- (IBAction)vertical:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(5) forKey:@"FormVal"];
    [self.view setNeedsLayout];
}
- (IBAction)eight:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(4) forKey:@"FormVal"];
    [self.view setNeedsLayout];
}
- (IBAction)infinity:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(3) forKey:@"FormVal"];
    [self.view setNeedsLayout];
}
- (IBAction)down:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:@"FormVal"];
    [self.view setNeedsLayout];
}
- (IBAction)up:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"FormVal"];
    [self.view setNeedsLayout];
}
- (IBAction)horizontal:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"FormVal"];
    [self.view setNeedsLayout];
}

- (IBAction)soundChanged:(UISegmentedControl *)sender {
    [self resetSprites];
}

- (IBAction)formChanged:(UISegmentedControl *)sender {
    [self resetSprites];
}

#define FLAT 0.75
- (void)setNode:(SKView *)view
{
    SKNode *node = [view.scene childNodeWithName:@"node"];
    [node removeAllActions];
    float w = view.scene.frame.size.width;
    float h = view.scene.frame.size.height;

    struct CGPath *pathl = CGPathCreateMutable();
    CGPathMoveToPoint(pathl, NULL, 0, 0);

    struct CGPath *pathr = CGPathCreateMutable();
    CGPathMoveToPoint(pathr, NULL, 0, 0);

    SKAction *reset;

    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"FormVal"]) {
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
        default:
            reset = [SKAction moveTo:CGPointMake(0, h/2) duration:0];

            CGPathAddLineToPoint(pathl, NULL, w, 0);

            CGPathAddLineToPoint(pathr, NULL, -w, 0);
            break;
    }

    SKAction *soundl;
    SKAction *soundr;

    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"SoundVal"]) {
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

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");

    [super viewDidLayoutSubviews];

    SKView *spriteView = (SKView *) self.view;
    IemdrScene *scene = [[IemdrScene alloc] initWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [spriteView presentScene:scene];

    self.bpmLabel.text = [NSString stringWithFormat:@"%.0f",
                          [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"]
                          ];
    self.durationLabel.text = [NSString stringWithFormat:@"%.0f",
                               [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"]
                               ];

    NSInteger form = [[NSUserDefaults standardUserDefaults] integerForKey:@"FormVal"];
    self.horizontal.tintColor = (form == 0 )? [UIColor redColor] : [UIColor whiteColor];
    self.up.tintColor = (form == 1 )? [UIColor redColor] : [UIColor whiteColor];
    self.down.tintColor = (form == 2 )? [UIColor redColor] : [UIColor whiteColor];
    self.infinity.tintColor = (form == 3 )? [UIColor redColor] : [UIColor whiteColor];
    self.eight.tintColor = (form == 4 )? [UIColor redColor] : [UIColor whiteColor];
    self.vertical.tintColor = (form == 5 )? [UIColor redColor] : [UIColor whiteColor];

    NSInteger sound = [[NSUserDefaults standardUserDefaults] integerForKey:@"SoundVal"];
    self.tictoc.tintColor = (sound == 0 )? [UIColor redColor] : [UIColor whiteColor];
    self.dong.tintColor = (sound == 1 )? [UIColor redColor] : [UIColor whiteColor];
    self.drums.tintColor = (sound == 2 )? [UIColor redColor] : [UIColor whiteColor];
    self.ding.tintColor = (sound == 3 )? [UIColor redColor] : [UIColor whiteColor];
    self.snip.tintColor = (sound == 4 )? [UIColor redColor] : [UIColor whiteColor];

    BOOL blank = [[NSUserDefaults standardUserDefaults] boolForKey:@"Blank"];
    self.blank.tintColor = blank ? [UIColor redColor] : [UIColor whiteColor];

    [self resetSprites];
}

@end
