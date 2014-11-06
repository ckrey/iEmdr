//
//  IEMDRAppDelegate.m
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "IEMDRAppDelegate.h"

@interface IEMDRAppDelegate()

@end

@implementation IEMDRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
							
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
