//
//  IEMDRAppDelegate.h
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IEMDRViewController.h"
#import "iEmdrCoreData.h"

@interface IEMDRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) iEmdrCoreData *data;

@end
