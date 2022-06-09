//
//  IEMDRViewController.m
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright © 2013-2022 Christoph Krey. All rights reserved.
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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (weak, nonatomic) IBOutlet UILabel *offsetLabel;
@property (weak, nonatomic) IBOutlet UITextField *offsetText;
@property (weak, nonatomic) IBOutlet UISlider *offsetSlider;

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

#define OFFSET_MAX 0.5
#define OFFSET_MIN -0.5
#define OFFSET_DEFAULT 0.0

#define BACKGROUND_MAX 1.0
#define BACKGROUND_MIN 0.0
#define BACKGROUND_DEFAULT 1.0

#define DURATION_MAX 600.0
#define DURATION_MIN 10.0
#define DURATION_DEFAULT 60.0

#define HUE_DEFAULT 1.0

#define FORM_DEFAULT 0
#define SOUND_DEFAULT 0

#define FLAT 0.75

@implementation IemdrVC
static const DDLogLevel ddLogLevel = DDLogLevelInfo;

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

    self.offsetSlider.minimumValue = OFFSET_MIN;
    self.offsetSlider.maximumValue = OFFSET_MAX;
    self.offsetSlider.value = OFFSET_DEFAULT;

    self.hueSlider.value = HUE_DEFAULT;
    
    self.speedSlider.minimumValue = BPM_MIN;
    self.speedSlider.maximumValue = BPM_MAX;
    self.speedSlider.value = BPM_DEFAULT;
    
    self.formSegment.selectedSegmentIndex = FORM_DEFAULT;
    self.soundSegment.selectedSegmentIndex = SOUND_DEFAULT;
    
    if (self.clientToRun &&
        self.clientToRun.hasSessions &&
        [self.clientToRun.hasSessions count]) {
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
        self.offsetSlider.value = [newestSession.offset floatValue];
        self.hueSlider.value = [newestSession.hue floatValue];
        self.speedSlider.value = [newestSession.frequency intValue];
    } else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud registerDefaults:@{
            @"sound": @(SOUND_DEFAULT),
            @"form": @(FORM_DEFAULT),
            @"duration": @(DURATION_DEFAULT),
            @"canvas": @(BACKGROUND_DEFAULT),
            @"size": @(RADIUS_DEFAULT),
            @"offset": @(OFFSET_DEFAULT),
            @"hue": @(HUE_DEFAULT),
            @"frequency": @(BPM_DEFAULT),
        }];
        self.soundSegment.selectedSegmentIndex = [ud integerForKey:@"sound"];
        self.formSegment.selectedSegmentIndex = [ud integerForKey:@"form"];
        self.durationSlider.value = [ud integerForKey:@"duration"];
        self.backgroundSlider.value = [ud floatForKey:@"canvas"];
        self.sizeSlider.value = [ud integerForKey:@"size"];
        self.offsetSlider.value = [ud floatForKey:@"offset"];
        self.hueSlider.value = [ud floatForKey:@"hue"];
        self.speedSlider.value = [ud integerForKey:@"frequency"];
    }

    [self setup];
    [self.view setNeedsDisplay];

#if !TARGET_OS_MACCATALYST
    [self checkForExistingScreenAndInitializeIfPresent];
#endif
}

- (void)setClientToRun:(Client *)clientToRun {
    _clientToRun = clientToRun;
    [self setClientName];
}

- (void)viewDidLoad {
    [super viewDidLoad];

#if !TARGET_OS_MACCATALYST
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleScreenConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];
#endif
    if (@available(iOS 13.0, *)) {
    } else {
        NSMutableArray <UIBarButtonItem *> *toolbarItems = [[self.toolbar items] mutableCopy];
        for (int i = 0; i < toolbarItems.count; i++) {
            if (toolbarItems[i].tag == 1) {
                toolbarItems[i] = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                   target:self
                                   action:@selector(played:)];
                self.playButton = toolbarItems[i];
            }
            if (toolbarItems[i].tag == 2) {
                toolbarItems[i] = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                   target:self
                                   action:@selector(stopped:)];
                self.stopButton = toolbarItems[i];
            }
            if (toolbarItems[i].tag == 4) {
                toolbarItems[i] = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                   target:self
                                   action:@selector(paused:)];
                self.pauseButton = toolbarItems[i];
            }
        }
        [self.toolbar setItems:toolbarItems];
    }
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
    [self offsetChanged:self.offsetSlider];
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
    [self stopped:nil];
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
    self.offsetLabel.textColor = textColor;
    self.offsetText.textColor = textColor;
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

    [self stopped:nil];
}

- (void)offsetHidden {
    self.offsetLabel.hidden = self.formSegment.hidden || self.formSegment.selectedSegmentIndex != 0;
    self.offsetText.hidden = self.formSegment.hidden || self.formSegment.selectedSegmentIndex != 0;
    self.offsetSlider.hidden = self.formSegment.hidden || self.formSegment.selectedSegmentIndex != 0;
}

- (IBAction)paused:(UIBarButtonItem *)sender {
    BOOL hidden = self.sizeLabel.isHidden ? FALSE : TRUE;

    NSString *name = self.clientToRun ? self.clientToRun.name : @">>";

    self.toolbarTitle.title = hidden ? @"" : name;
    
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

    [self offsetHidden];
    
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
    DDLogInfo(@"sizeChanged");
    self.sizeText.text = [NSString stringWithFormat:@"%3.0f", self.sizeSlider.value];
    [self stopped:nil];
}

- (IBAction)offsetChanged:(UISlider *)sender {
    DDLogInfo(@"offsetChanged");
    self.offsetText.text = [NSString stringWithFormat:@"%.2f", self.offsetSlider.value];
    [self stopped:nil];
}

- (IBAction)hueChanged:(UISlider *)sender {
    DDLogInfo(@"hueChanged");
    self.hueText.text = [NSString stringWithFormat:@"%2.1f", sender.value];
    [self stopped:nil];
}

- (IBAction)speedChanged:(UISlider *)sender {
    DDLogInfo(@"speedChanged");
    self.speedText.text = [NSString stringWithFormat:@"%3.0f", sender.value];
    [self stopped:nil];
}

- (IBAction)soundChanged:(UISegmentedControl *)sender {
    [self stopped:nil];
}

- (IBAction)formChanged:(UISegmentedControl *)sender {
    [self stopped:nil];
    [self offsetHidden];
}


- (IBAction)played:(UIBarButtonItem *)sender {
    [self resetSprites];
    self.started = [NSDate date];
    self.playButton.enabled = FALSE;
    self.stopButton.enabled = TRUE;

    self.passingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(timePassed:)
                                                       userInfo:nil
                                                        repeats:YES];
    [IemdrScene setNode:(SKView *)self.view
                   form:self.formSegment.selectedSegmentIndex
                 offset:self.offsetSlider.value
                  sound:self.soundSegment.selectedSegmentIndex];
    [IemdrScene setNode:self.big
                   form:self.formSegment.selectedSegmentIndex
                 offset:self.offsetSlider.value
                  sound:self.soundSegment.selectedSegmentIndex];
}

- (IBAction)stopped:(UIBarButtonItem *)sender {
    [self resetSprites];
    self.started = nil;
    self.playButton.enabled = TRUE;
    self.stopButton.enabled = FALSE;
}

- (void)resetSprites {
    DDLogInfo(@"resetSprites");
    [self resetNodes];
    if (self.passingTimer && self.passingTimer.isValid) {
        [self.passingTimer invalidate];
        [self sessionFinished];
    }
}

- (void)resetNodes {
    [IemdrScene resetNode:(SKView *)self.view
                     form:self.formSegment.selectedSegmentIndex
                   offset:self.offsetSlider.value
                   canvas:self.backgroundSlider.value
                   radius:self.sizeSlider.value
                      hue:self.hueSlider.value
                      bpm:self.speedSlider.value];
    [IemdrScene resetNode:self.big
                     form:self.formSegment.selectedSegmentIndex
                   offset:self.offsetSlider.value
                   canvas:self.backgroundSlider.value
                   radius:self.sizeSlider.value
                      hue:self.hueSlider.value
                      bpm:self.speedSlider.value];
}

- (void)sessionFinished {
    DDLogInfo(@"sessionFinished");
    if (self.clientToRun) {
        (void)[Session sessionWithTimestamp:[NSDate date]
                                   duration:@(self.durationSlider.value)
                             actualDuration:@([[NSDate date] timeIntervalSinceDate:self.started] / self.durationSlider.value)
                                     canvas:@(self.backgroundSlider.value)
                                        hue:@(self.hueSlider.value)
                                       size:@(self.sizeSlider.value)
                                     offset:@(self.offsetSlider.value)
                                  frequency:@(self.speedSlider.value)
                                       form:@(self.formSegment.selectedSegmentIndex)
                                      sound:@(self.soundSegment.selectedSegmentIndex)
                                     client:self.clientToRun
                     inManagedObjectContext:self.clientToRun.managedObjectContext];
        [self.clientToRun.managedObjectContext save:nil];
    } else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setInteger:self.soundSegment.selectedSegmentIndex forKey:@"sound"];
        [ud setInteger:self.formSegment.selectedSegmentIndex forKey:@"form"];
        [ud setInteger:self.durationSlider.value forKey:@"duration"];
        [ud setFloat:self.backgroundSlider.value forKey:@"canvas"];
        [ud setInteger:self.sizeSlider.value forKey:@"size"];
        [ud setFloat:self.offsetSlider.value forKey:@"offset"];
        [ud setFloat:self.hueSlider.value forKey:@"hue"];
        [ud setInteger:self.speedSlider.value forKey:@"frequency"];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    SKView *spriteView = (SKView *)self.view;
    spriteView.scene.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);

    return;
}

#if !TARGET_OS_MACCATALYST
#pragma Second Screen
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
#endif

@end
