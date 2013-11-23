//
//  IEMDRAppDelegate.m
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "IEMDRAppDelegate.h"

@interface IEMDRAppDelegate()

@property (strong, nonatomic) UIWindow *secondWindow;

@end

@implementation IEMDRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupScreenConnectionNotificationHandlers];
    
    self.data = [[iEmdrCoreData alloc] init];
    UIDocumentState state;
    
    do {
        state = self.data.documentState;
        if (state) {
#ifdef DEBUG
            NSLog(@"Waiting for document to open documentState = 0x%02x",
                  (unsigned short)self.data.documentState);
#endif
            if (state & UIDocumentStateInConflict || state & UIDocumentStateSavingError) {
                break;
            }
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    } while (state);
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self checkForExistingScreenAndInitializeIfPresent];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupScreenConnectionNotificationHandlers
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleScreenConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];
}

- (void)handleScreenConnectNotification:(NSNotification*)aNotification
{
    [self checkForExistingScreenAndInitializeIfPresent];
}

- (void)handleScreenDisconnectNotification:(NSNotification*)aNotification
{
    if (self.secondWindow)
    {
        // Hide and then delete the window.
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
    }
    self.iemdrVC.big = nil;
}

- (void)checkForExistingScreenAndInitializeIfPresent
{
    if ([[UIScreen screens] count] > 1)
    {
        // Associate the window with the second screen.
        // The main screen is always at index 0.
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        CGRect screenBounds = secondScreen.bounds;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"big" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"big"];
        self.secondWindow.rootViewController = viewController;
        SKView *skView = (SKView *)viewController.view;
        self.iemdrVC.big = skView;
        // Go ahead and show the window.
        self.secondWindow.hidden = NO;
    }
}


@end
