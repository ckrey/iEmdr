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
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIButton *stop;
@property (weak, nonatomic) IBOutlet UIButton *sample;

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

@property (weak, nonatomic) IBOutlet UILabel *sound;
@property (weak, nonatomic) IBOutlet UILabel *form;
@property (weak, nonatomic) IBOutlet UIButton *formSelect;
@property (weak, nonatomic) IBOutlet UIButton *soundSelect;

@property (nonatomic) NSTimeInterval timePassed;
@property (nonatomic) BOOL blank;
@property (strong, nonatomic) NSTimer *passingTimer;
@property (strong, nonatomic) NSDate *started;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.blank = FALSE;
    [self resetSprites];
}

- (IBAction)startPressed:(UIButton *)sender {
    self.blank = TRUE;
    [self startEmdr];
}

- (IBAction)samplePressed:(id)sender {
    self.blank = FALSE;
    [self startEmdr];
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    [self stopEmdr];
}

- (IBAction)stopPressed:(id)sender {
    [self stopEmdr];
}

- (void)stopEmdr {
    [self resetSprites];
    self.started = nil;

    self.progress.hidden = true;
    self.stop.hidden = true;
    self.start.hidden = false;
    self.sample.hidden = false;

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

    self.sound.hidden = false;
    self.soundSelect.hidden = false;
    self.form.hidden = false;
    self.formSelect.hidden = false;

    [self.view setNeedsFocusUpdate];
}

- (void)startEmdr {
    [self resetSprites];
    self.started = [NSDate date];
    [self.progress setProgress:0.0 animated:YES];

    if (self.blank) {
        self.progress.hidden = true;
        self.stop.hidden = true;
    } else {
        self.progress.hidden = false;
        self.stop.hidden = false;
    }
    self.start.hidden = true;
    self.sample.hidden = true;

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

    self.sound.hidden = true;
    self.soundSelect.hidden = true;
    self.form.hidden = true;
    self.formSelect.hidden = true;

    self.passingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(timePassed:)
                                                       userInfo:nil
                                                        repeats:YES];
    [self setNode:(SKView *)self.view];
    [self.view setNeedsFocusUpdate];
}

- (UIView *)preferredFocusedView {
    return self.start;
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
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasMax"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasFac"];
    val = MIN(max,(val * fac + inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"CanvasVal"];
    [self.view setNeedsLayout];
}
- (IBAction)canvasMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasMin"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasFac"];
    val = MAX(min,(val / fac - inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"CanvasVal"];
    [self.view setNeedsLayout];
}

- (IBAction)huePlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueVal"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueMax"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueFac"];
    val = MIN(max,(val * fac + inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"HueVal"];
    [self.view setNeedsLayout];
}
- (IBAction)hueMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueMin"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"HueFac"];
    val = MAX(min,(val / fac - inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"HueVal"];
    [self.view setNeedsLayout];
}

- (IBAction)sizePlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusVal"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusMax"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusFac"];

    val = MIN(max,(val * fac + inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"RadiusVal"];
    [self.view setNeedsLayout];
}
- (IBAction)sizeMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusMin"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusFac"];
    val = MAX(min,(val / fac - inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"RadiusVal"];
    [self.view setNeedsLayout];
}
- (IBAction)bpmPlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMMax"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMFac"];
    val = MIN(max,(val * fac + inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"BPMVal"];
    [self.view setNeedsLayout];
}
- (IBAction)bpmMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMMin"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMFac"];
    val = MAX(min,(val / fac - inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"BPMVal"];
    [self.view setNeedsLayout];
}
- (IBAction)durationPlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationMax"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationFac"];
    val = MIN(max,(val * fac + inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"DurationVal"];
    [self.view setNeedsLayout];
}
- (IBAction)durationMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationMin"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationFac"];
    val = MAX(min,(val / fac - inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"DurationVal"];
    [self.view setNeedsLayout];
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
    self.durationLabel.text = [NSString stringWithFormat:@"%.0f sec",
                               [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"]
                               ];

    NSInteger sound = [[NSUserDefaults standardUserDefaults] integerForKey:@"SoundVal"];
    NSArray *sounds = @[@"Tic Toc",@"Dong",@"Drums",@"Ding",@"Snip"];
    self.sound.text = sounds[sound];

    NSInteger form = [[NSUserDefaults standardUserDefaults] integerForKey:@"FormVal"];
    NSArray *forms = @[@"Horizontal",@"Diagonal Up",@"Diagonal Down",@"Infinity",@"Figure 8",@"Vertical"];
    self.form.text = forms[form];

    [self resetSprites];
}


- (IBAction)valuesUpdated:(UIStoryboardSegue *)unwindSegue {
    [self.view setNeedsLayout];
}

@end
