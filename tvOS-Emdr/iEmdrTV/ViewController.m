//
//  ViewController.m
//  OwnTracksCTRLTV
//
//  Created by Christoph Krey on 26.09.15.
//  Copyright © 2015-2020 OwnTracks. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "IemdrScene.h"
#import <AVFoundation/AVFoundation.h>
#import "CocoaLumberjack.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *help;
@property (weak, nonatomic) IBOutlet UILabel *headline;

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
@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet UILabel *formLabel;

@property (weak, nonatomic) IBOutlet UILabel *sound;
@property (weak, nonatomic) IBOutlet UILabel *form;
@property (weak, nonatomic) IBOutlet UIButton *formSelect;
@property (weak, nonatomic) IBOutlet UIButton *soundSelect;
@property (weak, nonatomic) IBOutlet UIButton *offsetPlus;
@property (weak, nonatomic) IBOutlet UIButton *offsetMinus;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *UIGesture;

@property (nonatomic) NSTimeInterval timePassed;
@property (strong, nonatomic) NSTimer *passingTimer;
@property (strong, nonatomic) NSDate *started;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) BOOL menuStop;

@end

#define FLAT 0.75

@implementation ViewController
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetSprites];
}

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    DDLogVerbose(@"pressesBegan");

    for (UIPress *press in [presses allObjects]) {
        DDLogVerbose(@"press %ld", (long)press.type);

        if (press.type == UIPressTypePlayPause) {
            if (self.started == nil) {
                [self startEmdr];
            } else {
                [self stopEmdr];
            }
            return;
        }
        if (press.type == UIPressTypeMenu) {
            if (self.started != nil) {
                [self stopEmdr];
                self.menuStop = true;
                return;
            }
        }
    }
    [super pressesBegan:presses withEvent:event];
}

- (void)pressesCancelled:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    DDLogVerbose(@"pressesCancelled");

    for (UIPress *press in [presses allObjects]) {
        DDLogVerbose(@"press %ld", (long)press.type);
        if (press.type == UIPressTypePlayPause) {
            return;
        }
        if (press.type == UIPressTypeMenu) {
            if (self.menuStop) {
                self.menuStop = false;
                return;
            }
        }
    }
    [super pressesCancelled:presses withEvent:event];
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    DDLogVerbose(@"pressesEnded");

    for (UIPress *press in [presses allObjects]) {
        DDLogVerbose(@"press %ld", (long)press.type);
        if (press.type == UIPressTypePlayPause) {
            return;
        }
        if (press.type == UIPressTypeMenu) {
            if (self.menuStop) {
                self.menuStop = false;
                return;
            }
        }
    }
    [super pressesEnded:presses withEvent:event];
}

- (void)stopEmdr {
    DDLogVerbose(@"stopEmdr");

    [self resetSprites];
    self.started = nil;

    self.help.hidden = false;
    self.headline.hidden = false;

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

    self.soundLabel.hidden = false;
    self.sound.hidden = false;
    self.soundSelect.hidden = false;
    self.formLabel.hidden = false;
    self.form.hidden = false;
    self.formSelect.hidden = false;

    [self offsetHidden];
    [self.view setNeedsFocusUpdate];
}

- (void)offsetHidden {
    NSInteger form = [[NSUserDefaults standardUserDefaults] integerForKey:@"FormVal"];
    self.offsetPlus.hidden = self.form.hidden || form != 0;
    self.offsetMinus.hidden = self.form.hidden || form != 0;
}

- (void)startEmdr {
    DDLogVerbose(@"startEmdr");

    [self resetSprites];
    self.started = [NSDate date];

    self.help.hidden = true;
    self.headline.hidden = true;
    
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

    self.soundLabel.hidden = true;
    self.sound.hidden = true;
    self.soundSelect.hidden = true;
    self.formLabel.hidden = true;
    self.form.hidden = true;
    self.formSelect.hidden = true;

    [self offsetHidden];

    self.passingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(timePassed:)
                                                       userInfo:nil
                                                        repeats:YES];
    [IemdrScene setNode:(SKView *)self.view
                   form:[[NSUserDefaults standardUserDefaults] integerForKey:@"FormVal"]
                 offset:[[NSUserDefaults standardUserDefaults] floatForKey:@"OffsetVal"]
                  sound:[[NSUserDefaults standardUserDefaults] integerForKey:@"SoundVal"]];
    [self.view setNeedsFocusUpdate];
}

- (void)timePassed:(NSTimer *)timer {
    float value = [[NSDate date] timeIntervalSinceDate:self.started] / [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"];
    DDLogVerbose(@"ticker %f", value);

    if (value >= 1.0) {
        [self stopEmdr];
    }
}

- (void)resetSprites {
    DDLogVerbose(@"resetSprites");
    [IemdrScene resetNode:(SKView *)self.view
                     form:[[NSUserDefaults standardUserDefaults] integerForKey:@"FormVal"]
                   offset:[[NSUserDefaults standardUserDefaults] floatForKey:@"OffsetVal"]
                   canvas:[[NSUserDefaults standardUserDefaults] doubleForKey:@"CanvasVal"]
                   radius:[[NSUserDefaults standardUserDefaults] doubleForKey:@"RadiusVal"]
                      hue:[[NSUserDefaults standardUserDefaults] doubleForKey:@"HueVal"]
                      bpm:[[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"]];

    if (self.passingTimer && self.passingTimer.isValid) {
        [self.passingTimer invalidate];
    }

    [self offsetHidden];
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
- (IBAction)offsetPlus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetVal"];
    double max = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetMax"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetFac"];
    val = MIN(max,(val / fac + inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"OffsetVal"];
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
- (IBAction)offsetMinus:(id)sender {
    double val = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetVal"];
    double min = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetMin"];
    double inc = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetInc"];
    double fac = [[NSUserDefaults standardUserDefaults] doubleForKey:@"OffsetFac"];
    val = MAX(min,(val / fac - inc));
    [[NSUserDefaults standardUserDefaults] setObject:@(val) forKey:@"OffsetVal"];
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

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"viewDidLayoutSubviews");

    [super viewDidLayoutSubviews];

    SKView *spriteView = (SKView *)self.view;
    IemdrScene *scene = [[IemdrScene alloc] initWithSize:CGSizeMake(spriteView.frame.size.width, spriteView.frame.size.height)];
    [spriteView presentScene:scene];

    self.bpmLabel.text = [NSString stringWithFormat:@"%.0f",
                          [[NSUserDefaults standardUserDefaults] doubleForKey:@"BPMVal"]
                          ];
    self.durationLabel.text = [NSString stringWithFormat:@"%.0f sec",
                               [[NSUserDefaults standardUserDefaults] doubleForKey:@"DurationVal"]
                               ];

    NSInteger sound = [[NSUserDefaults standardUserDefaults] integerForKey:@"SoundVal"];
    NSArray *sounds = @[@"Tic Toc",@"Dong",@"Drums",@"Ding",@"Snip",@"None"];
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
