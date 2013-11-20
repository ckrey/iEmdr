//
//  IEMDRViewController.m
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "IEMDRViewController.h"
#import "iEmdrAppDelegate.h"
#import "Client+Create.h"
#import "Session+Create.h"
#include <math.h>

#import <SpriteKit/SpriteKit.h>
#import "IEMDRScene.h"

@interface IEMDRViewController ()

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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;

@property (nonatomic) NSTimeInterval duration;
@property (strong, nonatomic) NSTimer *passingTimer;
@property (strong, nonatomic) NSDate *started;


@end

#define BPM_MAX 180.0
#define BPM_MIN 10.0
#define BPM_DEFAULT 30.0

#define RADIUS_MAX 100.0
#define RADIUS_MIN 5.0
#define RADIUS_DEFAULT 25.0

#define BACKGROUND_MAX 1.0
#define BACKGROUND_MIN 0.0
#define BACKGROUND_DEFAULT 0.2

#define DURATION_MAX 600.0
#define DURATION_MIN 10.0
#define DURATION_DEFAULT 60.0

#define HUE_DEFAULT 0.9


@implementation IEMDRViewController

- (void)setClientName
{
    NSString *name = self.clientToRun ? self.clientToRun.name : @">>";
    
    self.title = name;
    self.toolbarTitle.title = name;
}

- (void)setClientToRun:(Client *)clientToRun
{
    _clientToRun = clientToRun;
    [self setClientName];
}

- (void)setBig:(SKView *)big
{
    _big = big;
    if (big) {
        IEMDRScene *scene = [[IEMDRScene alloc] initWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
        [big presentScene:scene];
    }
}

- (void)viewDidLoad
{
    IEMDRAppDelegate *iemdrAD = [UIApplication sharedApplication].delegate;
    iemdrAD.iemdrVC = self;
    [self setClientName];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //
}

- (void)viewDidAppear:(BOOL)animated
{
    
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
        self.durationSlider.value = [newestSession.duration intValue];
        self.backgroundSlider.value = [newestSession.canvas floatValue];
        self.sizeSlider.value = [newestSession.size intValue];
        self.hueSlider.value = [newestSession.hue floatValue];
        self.speedSlider.value = [newestSession.frequency intValue];
    }
    
    [self durationChanged:self.durationSlider];
    [self backgroundChanged:self.backgroundSlider];
    [self sizeChanged:self.sizeSlider];
    [self hueChanged:self.hueSlider];
    [self speedChanged:self.speedSlider];
    
    [self stopped:nil];
}

- (IBAction)durationChanged:(UISlider *)sender {
    self.duration = sender.value;
    self.durationText.text = [NSString stringWithFormat:@"%3.0f", self.duration];
}

- (void)timePassed:(NSTimer *)timer
{
    float value = [[NSDate date] timeIntervalSinceDate:self.started] / self.durationSlider.value;
    NSLog(@"ticker %f", value);
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
    
    self.backgroundText.text = [NSString stringWithFormat:@"%2.1f", sender.value];
    
    SKView *spriteView = (SKView *)self.view;
    spriteView.scene.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:sender.value alpha:1.0];
    self.big.scene.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:sender.value alpha:1.0];

}
- (IBAction)paused:(UIBarButtonItem *)sender {
    BOOL hidden = self.sizeLabel.isHidden ?
    FALSE : TRUE;
    
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
    node.strokeColor = [UIColor colorWithHue:sender.value saturation:1.0 brightness:1.0 alpha:1.0];

    SKShapeNode *nodeBig = (SKShapeNode *)[self.big.scene childNodeWithName:@"node"];
    nodeBig.fillColor = [UIColor colorWithHue:sender.value saturation:1.0 brightness:1.0 alpha:1.0];
    nodeBig.strokeColor = [UIColor colorWithHue:sender.value saturation:1.0 brightness:1.0 alpha:1.0];

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
    
    self.passingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(timePassed:)
                                                       userInfo:nil
                                                        repeats:YES];
    self.playButton.enabled = FALSE;
    self.stopButton.enabled = TRUE;
    self.started = [NSDate date];

    SKView *spriteView = (SKView *) self.view;
    SKNode *node = [spriteView.scene childNodeWithName:@"node"];
    node.paused = FALSE;

    SKNode *nodeBig = [self.big.scene childNodeWithName:@"node"];
    nodeBig.paused = FALSE;
}

- (IBAction)stopped:(UIBarButtonItem *)sender {
    if (self.passingTimer) {
        [self.passingTimer invalidate];
    }
    self.playButton.enabled = TRUE;
    self.stopButton.enabled = FALSE;
    [self sessionFinished];

    SKView *spriteView = (SKView *)self.view;
    SKNode *node = [spriteView.scene childNodeWithName:@"node"];
    [node removeAllActions];

    float w = spriteView.scene.frame.size.width;
    float h = spriteView.scene.frame.size.height;
    SKAction *reset = [SKAction moveTo:CGPointMake(w/2, h/2) duration:0.25];
    [node runAction:reset completion:^{
        [self setNode:(SKView *)self.view];
        node.paused = TRUE;
    }];

    SKNode *nodeBig = [self.big.scene childNodeWithName:@"node"];
    [nodeBig removeAllActions];

    float wBig = self.big.scene.frame.size.width;
    float hBig = self.big.scene.frame.size.height;
    SKAction *resetBig = [SKAction moveTo:CGPointMake(wBig/2, hBig/2) duration:0.25];
    [nodeBig runAction:resetBig completion:^{
        [self setNode:self.big];
        nodeBig.paused = TRUE;
    }];

}

- (IBAction)formChanged:(UISegmentedControl *)sender {
    [self setNode:(SKView *)self.view];
    [self setNode:self.big];
}

- (void)setNode:(SKView *)view
{
    SKNode *node = [view.scene childNodeWithName:@"node"];
    [node removeAllActions];
    float w = view.scene.frame.size.width;
    float h = view.scene.frame.size.height;
    
    SKAction *reset = [SKAction moveTo:CGPointMake(w/2, h/2) duration:0];
    
    struct CGPath *path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    
    switch (self.formSegment.selectedSegmentIndex) {
        case 3:
            CGPathAddLineToPoint(path, NULL, -w/4, w/4);
            CGPathAddArc(path, NULL, -w/4, 0, w/4, M_PI/2, 2*M_PI-M_PI/2, NO);
            CGPathAddLineToPoint(path, NULL, w/4, w/4);
            CGPathAddArc(path, NULL, w/4, 0, w/4, M_PI/2, -M_PI/2, YES);
            CGPathCloseSubpath(path);
            break;
        case 2:
            CGPathAddLineToPoint(path, NULL, -(w/2), (h/2));
            CGPathAddLineToPoint(path, NULL, w/2, -h/2);
            CGPathCloseSubpath(path);
            break;
        case 1:
            CGPathAddLineToPoint(path, NULL, -(w/2), -(h/2));
            CGPathAddLineToPoint(path, NULL, w/2, h/2);
            CGPathCloseSubpath(path);
            break;
        case 0:
        default:
            CGPathAddLineToPoint(path, NULL, -w/2, 0);
            CGPathAddLineToPoint(path, NULL, w/2, 0);
            CGPathCloseSubpath(path);
            break;
    }
    
    SKAction *sound = [SKAction playSoundFileNamed:@"Kognitionen.m4a" waitForCompletion:NO];
    SKAction *action = [SKAction followPath:path duration:10.0];
    SKAction *sequence = [SKAction sequence:@[sound, reset, action]];
    
    [node runAction:[SKAction repeatActionForever:sequence]];
}

- (void)sessionFinished
{
    if (self.clientToRun) {
        (void)[Session sessionWithTimestamp:[NSDate date]
                                   duration:@(self.durationSlider.value)
                             actualDuration:@([[NSDate date] timeIntervalSinceDate:self.started] / self.durationSlider.value)
                                     canvas:@(self.backgroundSlider.value)
                                        hue:@(self.hueSlider.value)
                                       size:@(self.sizeSlider.value)
                                  frequency:@(self.speedSlider.value)
                                  form:@(self.formSegment.selectedSegmentIndex)
                                     client:self.clientToRun
                     inManagedObjectContext:self.clientToRun.managedObjectContext];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    NSMutableArray *barItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [barItems removeObject:_splitViewBarButtonItem];
    if (_splitViewBarButtonItem) [barItems insertObject:_splitViewBarButtonItem atIndex:0];
    self.toolbar.items = barItems;
    
    SKView *spriteView = (SKView *) self.view;    
    IEMDRScene *scene = [[IEMDRScene alloc] initWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [spriteView presentScene:scene];

}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *barItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [barItems removeObject:self.splitViewBarButtonItem];
    if (barButtonItem) [barItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = barItems;
    _splitViewBarButtonItem = barButtonItem;
    
}

@end
