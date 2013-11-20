//
//  IEMDRViewController.m
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "IEMDRViewController.h"
#import "iEmdrView.h"
#import "iEmdrAppDelegate.h"
#import "Client+Create.h"
#import "Session+Create.h"
#include <math.h>

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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopButton;

@property (weak, nonatomic) IBOutlet iEmdrView *light;

@end

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

- (void)viewDidLoad
{
    IEMDRAppDelegate *iemdrAD = [UIApplication sharedApplication].delegate;
    iemdrAD.iemdrVC = self;
    [self setClientName];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    self.durationSlider.minimumValue = [iEmdrView minDuration];
    self.durationSlider.maximumValue = [iEmdrView maxDuration];
    self.durationSlider.value = [iEmdrView defaultDuration];
    
    self.backgroundSlider.minimumValue = [iEmdrView minBackground];
    self.backgroundSlider.maximumValue = [iEmdrView maxBackground];
    self.backgroundSlider.value = [iEmdrView defaultBackground];
    
    self.sizeSlider.minimumValue = [iEmdrView minRadius];
    self.sizeSlider.maximumValue = [iEmdrView maxRadius];
    self.sizeSlider.value = [iEmdrView defaultRadius];
    
    self.light.color = [UIColor redColor];
    CGFloat hue, saturation, brightness, alpha;
    [[UIColor redColor] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    self.hueSlider.value = hue;
    
    self.speedSlider.minimumValue = [iEmdrView minBpm];
    self.speedSlider.maximumValue = [iEmdrView maxBpm];
    self.speedSlider.value = [iEmdrView defaultBpm];
    
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
    
    self.light.observer = self;
    self.light.on = FALSE;
    
    self.playButton.enabled = TRUE;
    self.stopButton.enabled = FALSE;
    
    [self.light setNeedsDisplay];
    
    [self setBigLight:self.bigLight];
    [self.bigLight setNeedsDisplay];
    
}

- (void)setBigLight:(iEmdrView *)bigLight
{
    _bigLight = bigLight;
    
    if (_bigLight) {
        _bigLight.background = self.light.background;
        _bigLight.color = self.light.color;
        _bigLight.radius = self.light.radius;
        _bigLight.duration = self.light.duration;
        _bigLight.bpm = self.light.bpm;
        _bigLight.on = self.light.on;
    }
}

- (IBAction)durationChanged:(UISlider *)sender {
    self.light.duration = sender.value;
    self.durationText.text = [NSString stringWithFormat:@"%3.0f", self.light.duration];
    [self setBigLight:self.bigLight];
}

- (void)valueChanged
{
    double value = self.light.progress;
    [self.progress setProgress:value animated:YES];
    
    if (self.light.on) {
        self.playButton.enabled = FALSE;
        self.stopButton.enabled = TRUE;
    } else {
        self.playButton.enabled = TRUE;
        self.stopButton.enabled = FALSE;
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
    
    self.light.background = sender.value;
    self.backgroundText.text = [NSString stringWithFormat:@"%2.1f", sender.value];
    [self setBigLight:self.bigLight];
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
    
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
}

- (IBAction)sizeChanged:(UISlider *)sender {
    self.light.radius = sender.value;
    self.sizeText.text = [NSString stringWithFormat:@"%3.0f", self.light.radius];
    [self setBigLight:self.bigLight];
}

- (IBAction)hueChanged:(UISlider *)sender {
    CGFloat hue, saturation, brightness, alpha;
    [self.light.color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    self.light.color = [UIColor colorWithHue:sender.value saturation:saturation brightness:brightness alpha:alpha];
    self.hueText.text = [NSString stringWithFormat:@"%2.1f", sender.value];
    [self setBigLight:self.bigLight];
}

- (IBAction)speedChanged:(UISlider *)sender {
    self.light.bpm = sender.value;
    self.speedText.text = [NSString stringWithFormat:@"%3.0f", self.light.bpm];
    [self setBigLight:self.bigLight];
}

- (IBAction)played:(UIBarButtonItem *)sender {
    self.playButton.enabled = FALSE;
    self.stopButton.enabled = TRUE;
    self.light.on = TRUE;
    [self setBigLight:self.bigLight];
}

- (IBAction)stopped:(UIBarButtonItem *)sender {
    self.playButton.enabled = TRUE;
    self.stopButton.enabled = FALSE;
    self.light.on = FALSE;
    [self setBigLight:self.bigLight];
    [self sessionFinished];
}


- (void)sessionFinished
{
    if (self.clientToRun) {
        CGFloat hue, saturation, brightness, alpha;
        [self.light.color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        
        (void)[Session sessionWithTimestamp:[NSDate date]
                                   duration:@(self.light.duration)
                             actualDuration:@(self.light.progress)
                                     canvas:@(self.light.background)
                                        hue:@(hue)
                                       size:@(self.light.radius)
                                  frequency:@(self.light.bpm)
                                     client:self.clientToRun
                     inManagedObjectContext:self.clientToRun.managedObjectContext];
    }
}

- (void)viewDidLayoutSubviews
{
    NSMutableArray *barItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [barItems removeObject:_splitViewBarButtonItem];
    if (_splitViewBarButtonItem) [barItems insertObject:_splitViewBarButtonItem atIndex:0];
    self.toolbar.items = barItems;
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
