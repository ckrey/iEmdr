//
//  IEMDRAppDelegate.m
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright © 2013-2022 Christoph Krey. All rights reserved.
//

#import "IemdrAD.h"
#import "CocoaLumberjack.h"

@interface IemdrAD()

@end

@implementation IemdrAD
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder  API_AVAILABLE(ios(13.0)){
    [builder removeMenuForIdentifier:UIMenuHelp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [DDLog addLogger:[DDOSLogger sharedInstance]];

    self.data = [[iEmdrCoreData alloc] init];
    UIDocumentState state;
    
    do {
        state = self.data.documentState;
        if (state) {
            DDLogVerbose(@"Waiting for document to open documentState = 0x%02x",
                  (unsigned short)self.data.documentState);
            if (state & UIDocumentStateInConflict || state & UIDocumentStateSavingError) {
                break;
            }
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    } while (state);
    return YES;
}

@end
