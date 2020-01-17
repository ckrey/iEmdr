//
//  IEMDRViewController.m
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import "IemdrVC.h"
#import "IemdrAD.h"
#import "Client+CoreDataClass.h"
#import "Session+CoreDataClass.h"
#include <math.h>

#import <SpriteKit/SpriteKit.h>
#import "IemdrScene.h"

#import <AVFoundation/AVFoundation.h>

#import "CocoaLumberjack.h"

@interface IemdrVC ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolbarTitle;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UITextField *sizeText;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;

@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (weak, nonatomic) IBOutlet UITextField *backgroundText;
@property (weak, nonatomic) IBOutlet UISlider *backgroundSlider;

@property (weak, nonatomic) IBOutlet UILabel *hueLabel;
@property (weak, nonatomic) IBOutlet UITextField *hueText;
@property (weak, nonatomic) IBOutlet UISlider *hueSlider;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UITextField *speedText;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UITextField *durationText;
@property (weak, nonatomic) IBOutlet UISlider *durationSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *formSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *soundSegment;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;

@property (nonatomic) NSTimeInterval duration;
@property (strong, nonatomic) NSTimer *passingTimer;
@property (strong, nonatomic) NSDate *started;

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@property (weak, nonatomic) SKView *big;
@property (strong, nonatomic) UIWindow *secondWindow;

@end

#define BPM_MAX 180.0
#define BPM_MIN 10.0
#define BPM_DEFAULT 30.0

#define RADIUS_MAX 100.0
#define RADIUS_MIN 5.0
#define RADIUS_DEFAULT 25.0

#define BACKGROUND_MAX 1.0
#define BACKGROUND_MIN 0.0
#define BACKGROUND_DEFAULT 1.0

#define DURATION_MAX 600.0
#define DURATION_MIN 10.0
#define DURATION_DEFAULT 60.0

#define HUE_DEFAULT 1.0

#define FORM_DEFAULT 0
#define SOUND_DEFAULT 0

@implementation IemdrVC
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)setClientName {
    NSString *name = self.clientToRun ? self.clientToRun.name : @">>";
    
    self.title = name;
    self.toolbarTitle.title = name;
    self.durationSlider.minimumValue = DURATION_MIN;
    self.durationSlider.maximumValue = DURATION_MAX;
    self.durationSlider.value = DURATION_DEFAULT;
    
    self.backgroundSlider.minimumValue = BACKGROUND_MIN;
    self.backgroundSlider.maximumValue = BACKGROUND_MAX;
    self.backgroundSlider.value = BACKGROUND_DEFAULT;
    
    self.sizeSlider.minimumValue = RADIUS_MIN;
    self.sizeSlider.maximumValue = RADIUS_MAX;
    self.sizeSlider.value = RADIUS_DEFAULT;
    
    self.hueSlider.value = HUE_DEFAULT;
    
    self.speedSlider.minimumValue = BPM_MIN;
    self.speedSlider.maximumValue = BPM_MAX;
    self.speedSlider.value = BPM_DEFAULT;
    
    self.formSegment.selectedSegmentIndex = FORM_DEFAULT;
    self.soundSegment.selectedSegmentIndex = SOUND_DEFAULT;
    
    if (self.clientToRun && self.clientToRun.hasSessions && [self.clientToRun.hasSessions count]) {
        Session *newestSession;
        
        for (Session *session in self.clientToRun.hasSessions) {
            if (!newestSession) {
                newestSession = session;
            } else {
                if ([newestSession.timestamp compare:session.timestamp] == NSOrderedAscending) {
                    newestSession = session;
                }
            }
        }
        self.soundSegment.selectedSegmentIndex = [newestSession.sound intValue];
        self.formSegment.selectedSegmentIndex = [newestSession.form intValue];
        self.durationSlider.value = [newestSession.duration intValue];
        self.backgroundSlider.value = [newestSession.canvas floatValue];
        self.sizeSlider.value = [newestSession.size intValue];
        self.hueSlider.value = [newestSession.hue floatValue];
        self.speedSlider.value = [newestSession.frequency intValue];
    }
    [self backgroundChanged:self.backgroundSlider];
    [self.view setNeedsDisplay];
    
    [self checkForExistingScreenAndInitializeIfPresent];
}

- (void)setClientToRun:(Client *)clientToRun {
    _clientToRun = clientToRun;
    [self setClientName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleScreenConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];
    
    [self setClientName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setClientName];
    if (self.splitViewController.isCollapsed) {
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
    } else {
        self.splitViewController.preferredDisplayMode =  UISplitViewControllerDisplayModeAllVisible;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resetSprites];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setup];
}

- (void)setup {
    SKView *spriteView = (SKView *)self.view;
    IemdrScene *scene = [[IemdrScene alloc] initWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [spriteView presentScene:scene];


    [self soundChanged:self.soundSegment];
    [self formChanged:self.formSegment];
    [self durationChanged:self.durationSlider];
    [self backgroundChanged:self.backgroundSlider];
    [self sizeChanged:self.sizeSlider];
    [self hueChanged:self.hueSlider];
    [self speedChanged:self.speedSlider];
    
    [self resetSprites];
    [self.toolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
}

- (IBAction)durationChanged:(UISlider *)sender {
    self.duration = sender.value;
    self.durationText.text = [NSString stringWithFormat:@"%3.0f", self.duration];
}

- (void)timePassed:(NSTimer *)timer {
    float value = [[NSDate date] timeIntervalSinceDate:self.started] / self.durationSlider.value;
    DDLogVerbose(@"ticker %f", value);
    [self.progress setProgress:value animated:YES];
    
    if (value >= 1.0) {
        [self stopped:nil];
    }
}

- (IBAction)backgroundChanged:(UISlider *)sender {
    UIColor *textColor = (sender.value > 0.5) ? [UIColor darkTextColor] : [UIColor lightTextColor];
    
    self.sizeLabel.textColor = textColor;
    self.sizeText.textColor = textColor;
    self.speedLabel.textColor = textColor;
    self.speedText.textColor = textColor;
    self.backgroundLabel.textColor = textColor;
    self.backgroundText.textColor = textColor;
    self.hueLabel.textColor = textColor;
    self.hueText.textColor = textColor;
    self.durationLabel.textColor = textColor;
    self.durationText.textColor = textColor;
    self.toolbarTitle.tintColor = textColor;
    
    self.backgroundText.text = [NSString stringWithFormat:@"%2.1f", sender.value];
    
    SKView *spriteView = (SKView *)self.view;
    spriteView.scene.backgroundColor = [UIColor colorWithHue:1.0
                                                  saturation:0.0
                                                  brightness:sender.value
                                                       alpha:1.0];
    self.big.scene.backgroundColor = [UIColor colorWithHue:1.0
                                                saturation:0.0
                                                brightness:sender.value
                                                     alpha:1.0];
    
}
- (IBAction)paused:(UIBarButtonItem *)sender {
    BOOL hidden = self.sizeLabel.isHidden ? FALSE : TRUE;
    
    self.sizeLabel.hidden = hidden;
    self.sizeText.hidden = hidden;
    self.sizeSlider.hidden = hidden;
    
    self.speedLabel.hidden = hidden;
    self.speedText.hidden = hidden;
    self.speedSlider.hidden = hidden;
    
    self.backgroundLabel.hidden = hidden;
    self.backgroundText.hidden = hidden;
    self.backgroundSlider.hidden = hidden;
    
    self.hueLabel.hidden = hidden;
    self.hueText.hidden = hidden;
    self.hueSlider.hidden = hidden;
    
    self.durationLabel.hidden = hidden;
    self.durationText.hidden = hidden;
    self.durationSlider.hidden = hidden;
    
    self.formSegment.hidden = hidden;
    self.soundSegment.hidden = hidden;
    
    if (self.splitViewController.isCollapsed) {
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
    } else {
        if (hidden) {
            self.splitViewController.preferredDisplayMode =  UISplitViewControllerDisplayModePrimaryHidden;
        } else {
            self.splitViewController.preferredDisplayMode =  UISplitViewControllerDisplayModeAllVisible;
        }
    }

    [self.navigationController setNavigationBarHidden:hidden animated:YES];
}

- (IBAction)sizeChanged:(UISlider *)sender {
    self.sizeText.text = [NSString stringWithFormat:@"%3.0f", self.sizeSlider.value];
    
    SKView *spriteView = (SKView *) self.view;
    SKShapeNode *node = (SKShapeNode *)[spriteView.scene childNodeWithName:@"node"];
    node.path = CGPathCreateWithEllipseInRect(CGRectMake(-sender.value, -sender.value, sender.value*2, sender.value*2), NULL);
    
    SKShapeNode *nodeBig = (SKShapeNode *)[self.big.scene childNodeWithName:@"node"];
    nodeBig.path = CGPathCreateWithEllipseInRect(CGRectMake(-sender.value, -sender.value, sender.value*2, sender.value*2), NULL);
}

- (IBAction)hueChanged:(UISlider *)sender {
    self.hueText.text = [NSString stringWithFormat:@"%2.1f", sender.value];
    
    SKView *spriteView = (SKView *) self.view;
    SKShapeNode *node = (SKShapeNode *)[spriteView.scene childNodeWithName:@"node"];
    node.fillColor = [UIColor colorWithHue:sender.value saturation:1.0 brightness:1.0 alpha:1.0];
    //node.strokeColor = [UIColor colorWithHue:sender.value saturation:1.0 brightness:1.0 alpha:1.0];
    
    SKShapeNode *nodeBig = (SKShapeNode *)[self.big.scene childNodeWithName:@"node"];
    nodeBig.fillColor = [UIColor colorWithHue:sender.value saturation:1.0 brightness:1.0 alpha:1.0];
    //nodeBig.strokeColor = [UIColor colorWithHue:sender.value saturation:1.0 brightness:1.0 alpha:1.0];
    
}

- (IBAction)speedChanged:(UISlider *)sender {
    self.speedText.text = [NSString stringWithFormat:@"%3.0f", sender.value];
    
    SKView *spriteView = (SKView *) self.view;
    SKShapeNode *node = (SKShapeNode *)[spriteView.scene childNodeWithName:@"node"];
    node.speed = sender.value / 6;
    
    SKShapeNode *nodeBig = (SKShapeNode *)[self.big.scene childNodeWithName:@"node"];
    nodeBig.speed = sender.value / 6;
}

- (IBAction)played:(UIBarButtonItem *)sender {
    [self resetSprites];
    self.passingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(timePassed:)
                                                       userInfo:nil
                                                        repeats:YES];
    self.playButton.enabled = FALSE;
    self.stopButton.enabled = TRUE;
    self.started = [NSDate date];
    
    [self setNode:(SKView *)self.view];
    [self setNode:self.big];
}

- (IBAction)stopped:(UIBarButtonItem *)sender {
    [self sessionFinished];
    [self resetSprites];
}

- (void)resetSprites {
    if (self.passingTimer && self.passingTimer.isValid) {
        [self.passingTimer invalidate];
    }
    
    self.playButton.enabled = TRUE;
    self.stopButton.enabled = FALSE;
    
    SKView *spriteView = (SKView *)self.view;
    SKNode *node = [spriteView.scene childNodeWithName:@"node"];
    [node removeAllActions];
    
    float w = spriteView.scene.frame.size.width;
    float h = spriteView.scene.frame.size.height;
    SKAction *reset = [SKAction moveTo:CGPointMake(w/2, h/2) duration:0.25];
    [node runAction:reset];
    
    SKNode *nodeBig = [self.big.scene childNodeWithName:@"node"];
    [nodeBig removeAllActions];
    
    float wBig = self.big.scene.frame.size.width;
    float hBig = self.big.scene.frame.size.height;
    SKAction *resetBig = [SKAction moveTo:CGPointMake(wBig/2, hBig/2) duration:0.25];
    [nodeBig runAction:resetBig];
}

- (IBAction)soundChanged:(UISegmentedControl *)sender {
    [self stopped:nil];
}

- (IBAction)formChanged:(UISegmentedControl *)sender {
    [self stopped:nil];
}

#define FLAT 0.75
- (void)setNode:(SKView *)view {
    SKNode *node = [view.scene childNodeWithName:@"node"];
    [node removeAllActions];
    float w = view.scene.frame.size.width;
    float h = view.scene.frame.size.height;
    
    struct CGPath *pathl = CGPathCreateMutable();
    CGPathMoveToPoint(pathl, NULL, 0, 0);
    
    struct CGPath *pathr = CGPathCreateMutable();
    CGPathMoveToPoint(pathr, NULL, 0, 0);
    
    SKAction *reset;
    
    switch (self.formSegment.selectedSegmentIndex) {
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
    
    switch (self.soundSegment.selectedSegmentIndex) {
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

- (void)sessionFinished {
    if (self.clientToRun) {
        (void)[Session sessionWithTimestamp:[NSDate date]
                                   duration:@(self.durationSlider.value)
                             actualDuration:@([[NSDate date] timeIntervalSinceDate:self.started] / self.durationSlider.value)
                                     canvas:@(self.backgroundSlider.value)
                                        hue:@(self.hueSlider.value)
                                       size:@(self.sizeSlider.value)
                                  frequency:@(self.speedSlider.value)
                                       form:@(self.formSegment.selectedSegmentIndex)
                                      sound:@(self.soundSegment.selectedSegmentIndex)
                                     client:self.clientToRun
                     inManagedObjectContext:self.clientToRun.managedObjectContext];
        [self.clientToRun.managedObjectContext save:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    SKView *spriteView = (SKView *)self.view;
    spriteView.scene.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);

    //[self soundChanged:self.soundSegment];
    //[self formChanged:self.formSegment];
    [self durationChanged:self.durationSlider];
    [self backgroundChanged:self.backgroundSlider];
    [self sizeChanged:self.sizeSlider];
    [self hueChanged:self.hueSlider];
    [self speedChanged:self.speedSlider];
    
    return;
}

- (void)handleScreenConnectNotification:(NSNotification *)notification {
    UIScreen *screen = (UIScreen *)notification.object;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Second Screen"
                                                                message:[NSString stringWithFormat:@"connected %.0f x %.0f pixels",
                                                                         screen.bounds.size.width,
                                                                         screen.bounds.size.height]
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [ac addAction:ok];
    [self presentViewController:ac animated:TRUE completion:nil];
    [self checkForExistingScreenAndInitializeIfPresent];
}

- (void)handleScreenDisconnectNotification:(NSNotification *)notification {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Second Screen"
                                                                message:@"disconnected"
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [ac addAction:ok];
    [self presentViewController:ac animated:TRUE completion:nil];
    if (self.secondWindow) {
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
    }
    self.big = nil;
}

- (void)checkForExistingScreenAndInitializeIfPresent {
    NSArray *screens = [UIScreen screens];
    if ([screens count] > 1) {
        UIScreen *secondScreen = (UIScreen *)screens[1];
        CGRect screenBounds = secondScreen.bounds;
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"big" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"big"];
        self.secondWindow.rootViewController = viewController;
        SKView *skView = (SKView *)viewController.view;
        self.big = skView;
        self.secondWindow.hidden = NO;
        [self setup];
    }
}

@end
